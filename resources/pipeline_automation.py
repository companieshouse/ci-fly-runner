''' Python script that detected commit changes and creates pipeline changes '''
import logging
import os
import sys
import subprocess
import shlex
import yaml
import git


# Configure logging
log_filename = os.path.splitext(os.path.basename(__file__))[0] + '.log'
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(filename)s - %(message)s",
    handlers=[
        logging.FileHandler(log_filename),
        logging.StreamHandler()
    ]
)


# Classes
class Fly:
    ''' Class to run fly command '''
    def __init__(self, target):
        self.target = target

    # TODO: Will need RegEx
    # TODO: Process failed execution
    def login(self, username, password):
        ''' Login to Concourse with Fly '''
        login_command = f'fly -t {self.target} login -u "{username}" -p "{password}"'
        logging.info("Logging into Concourse target: %s", self.target)
        process = subprocess.run(login_command, shell=True, check=True, \
                                    capture_output=True, text=True)
        logging.debug(process.stdout)
        if list(filter(None, process.stdout.split('\n'))) != \
                ["logging in to team 'main'", 'target saved']:
            raise ValueError(f"Failed to log into Concourse target: {self.target}")

    def validate_pipeline(self, pipeline_path):
        ''' Validate a pipeline file with Fly '''
        validate_command = f'fly -t "{self.target}" validate-pipeline -c "{pipeline_path}"'
        logging.info("Validating pipeline: %s", pipeline_path)
        process = subprocess.run(validate_command, shell=True, \
                                    capture_output=True, text=True)
        logging.debug(process.stdout)
        if list(filter(None, process.stdout.split('\n'))) != ['looks good']:
            return False
        return True

    def set_pipeline(self, pipeline_path):
        ''' Set a pipeline using Fly '''
        pipeline_name = self.get_pipeline_name(pipeline_path)
        set_command = f'fly -t "{self.target}" ' +  \
            f'set-pipeline -p {pipeline_name} -c "{pipeline_path}" -n'
        logging.info("Setting pipeline: %s", pipeline_path)
        process = subprocess.run(set_command, shell=True, check=True, \
                                    capture_output=True, text=True)
        logging.debug(process.stdout)

    def destroy_pipeline(self, pipeline_path):
        ''' Destroy a pipeline using Fly '''
        pipeline_name = self.get_pipeline_name(pipeline_path)
        set_command = f'fly -t "{self.target}" destroy-pipeline -p {pipeline_name} -n'
        logging.info("Destroying pipeline: %s", pipeline_name)
        process = subprocess.run(set_command, shell=True, check=True, \
                                    capture_output=True, text=True)
        logging.debug(process.stdout)

    def get_pipeline_name(self, path):
        ''' Sanitise and return the pipeline name '''
        return shlex.quote(os.path.splitext(os.path.basename(path))[0])

class PipelineRepository():
    ''' Class to manage pipeline repository changes '''
    def __init__(self, directory):
        ''' Take a directory and turn it into a Repo object '''
        self.repo = git.Repo(directory)
        logging.info("Found repository: %s", directory)

        assert not self.repo.bare, "Repository is bare"
        logging.debug("Repository is not bare")

        assert not self.repo.is_dirty(), "Repository is dirty"
        logging.debug("Repository is not dirty")

        # End / needed to stop names like pipelinesX
        self.pipeline_folder = f"{self.repo.working_dir}/pipelines/"

    def get_pipeline_changes(self):
        ''' Collect changes from diff relating to pipeline objects '''

        if not self.repo:
            raise AssertionError("A repository needs to be initialised first")

        try:
            current_commit = self.repo.head.commit
        except ValueError as ex:
            logging.critical("Failed to get any git commits")
            raise ex

        logging.info("Current commit: %s", current_commit)

        pipeline_changes = []
        parent_commit = current_commit.parents[0] if current_commit.parents else None
        if parent_commit:
            logging.info("Parent commit: %s", parent_commit)
            for change in parent_commit.diff(current_commit):
                # Change Types:
                #  'A' for added paths
                #  'D' for deleted paths
                #  'R' for renamed paths
                #  'M' for paths with modified data
                #  'T' for changed in the type paths
                logging.info("Change found - Path: %s Type: %s", change.b_path, change.change_type)

                if not (self.repo.working_dir + '/' + change.b_path) \
                        .startswith(self.pipeline_folder):
                    logging.debug("Not in pipeline directory: %s", change.b_path)
                    continue

                if change.change_type == 'T':
                    if get_yaml(self.repo.working_dir + '/' + change.b_path):
                        pipeline_changes.append(
                            {'action':'set-pipeline', 'path': change.b_path}
                        )
                        logging.info("Action: set-pipeline for %s", change.b_path)
                    else:
                        logging.info("File is not valid yaml: %s", change.b_path)

                elif change.change_type in ('A', 'M'):
                    pipeline_changes.append(
                        {'action':'set-pipeline', 'path': change.b_path}
                    )
                    logging.info("Action: set-pipeline for %s", change.b_path)

                elif change.change_type == 'R':
                    pipeline_changes.append(
                        {'action':'destroy-pipeline', 'path': change.a_path}
                    )
                    logging.info("Action: destroy-pipeline for %s", change.a_path)

                    pipeline_changes.append(
                        {'action':'set-pipeline', 'path': change.b_path}
                    )
                    logging.info("Action: set-pipeline for %s", change.b_path)

                elif change.change_type == 'D':
                    pipeline_changes.append(
                        {'action':'destroy-pipeline', 'path': change.b_path}
                    )
                    logging.info("Action: destroy-pipeline for %s", change.b_path)
        else:
            logging.info("Found singular commit")
            for change in current_commit.tree.list_traverse():
                if not (self.repo.working_dir + '/' + change.path).startswith(self.pipeline_folder):
                    logging.debug("Not in pipeline directory: %s", change.path)
                    continue

                pipeline_changes.append(
                    {'action':'set-pipeline', 'path': change.path}
                )
                logging.info("Action: set-pipeline for %s", change.path)

        logging.debug("Staged changes: %s", pipeline_changes)
        return pipeline_changes


# Functions
def get_yaml(file_path):
    ''' Get the yaml from a file '''
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return yaml.safe_load(file)
    except yaml.YAMLError:
        return False


# Main
if __name__ == '__main__':
    # Welcome message
    logging.info("Pipeline Automation Container V0.1")

    ENV_NAME = "PIPELINE_GIT_REPOSITORY"
    pipeline_folder = os.getenv(ENV_NAME)
    if pipeline_folder is None:
        raise AssertionError(f"'{ENV_NAME}' is not set in the environment but is required.")

    # Open the repository
    pipeline_repo = PipelineRepository(os.path.abspath(pipeline_folder))

    # Get pipeline change: adding,updating,removing
    changes = pipeline_repo.get_pipeline_changes()

    # Exit if no changes
    if not changes:
        logging.info("No pipeline changes found")
        sys.exit()

    # Apply changes
    session = Fly('concourse')
    session.login('test', 'test')

    successful_pipelines = []
    destroyed_pipelines = []
    failed_pipelines = []
    for pipeline in changes:
        abs_file_path = os.path.join(pipeline_repo.repo.working_dir, pipeline['path'])
        if pipeline['action'] == 'set-pipeline':
            # Test loading yaml
            if not get_yaml(abs_file_path):
                logging.warning('Failed to validate yml: %s', abs_file_path)
                failed_pipelines.append(pipeline)
                continue

            if not session.validate_pipeline(abs_file_path):
                logging.warning('Failed to fly validate: %s', abs_file_path)
                failed_pipelines.append(pipeline)
                continue

            successful_pipelines.append(pipeline)
            session.set_pipeline(abs_file_path)

        elif pipeline['action'] == 'destroy-pipeline':
            destroyed_pipelines.append(pipeline)
            session.destroy_pipeline(abs_file_path)

    # Results
    print('Pipeline Automation Results')
    print(f'\tSuccessful: {len(successful_pipelines)}')
    for pipeline in successful_pipelines:
        print(f"\t\t- {pipeline['path']}")

    print(f'\tDestroyed: {len(destroyed_pipelines)}')
    for pipeline in destroyed_pipelines:
        print(f"\t\t- {pipeline['path']}")

    print(f'\tFailed: {len(failed_pipelines)}')
    for pipeline in failed_pipelines:
        print(f"\t\t- {pipeline['path']}")
