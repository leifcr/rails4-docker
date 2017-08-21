#!/bin/bash
set +e

# Check if env is set
if [ ! -z ${SSH_AUTH_SOCK+x} ]; then
  # echo 'Loading ssh-agent if not already loaded'
  ssh-add -l &>/dev/null
  if [ "$?" == 2 ]; then
    echo "starting ssh agent"
    eval "ssh-agent -a $SSH_AUTH_SOCK" >/dev/null
  fi
fi

set -e
case "$1" in
        annotate|cap|capify|cucumber|foodcritic|guard|irb|jekyll|kitchen|knife)
        command="bundle exec $@";;
        middleman|nanoc|pry|puma|rackup|rainbows|rails|rake|rspec|shotgun|sidekiq|spec)
        command="bundle exec $@";;
        spork|spring|strainer|tailor|taps|thin|thor|unicorn|unicorn_rails)
        command="bundle exec $@";;
        *)
        command="$@";;
esac
exec ${command}
