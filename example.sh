#!/bin/sh

set -u

node ./index.mjs |
	arrow-cat
