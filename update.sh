#!/bin/sh
cp Gemfile* no_entry_point/
cp Gemfile* with_ssh_agent/
git commit -a -m 'Update gems'
