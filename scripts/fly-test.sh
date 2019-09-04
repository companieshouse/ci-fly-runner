#!/bin/sh

echo Testing Fly version: $flyversion
fly --version | grep ${flyversion}
