#!/usr/bin/env bash
mkdir -p archives
git archive HEAD -o archives/$1.tar.gz 