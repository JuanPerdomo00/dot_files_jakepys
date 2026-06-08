export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

pipewire &
wireplumber &
pipewire-pulse &

exec i3
