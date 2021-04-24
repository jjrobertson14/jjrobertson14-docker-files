#!/bin/bash

bunzip2 /home/rhythm/home_rhythm.tar.bz2 
tar -xf /home/rhythm/home_rhythm.tar -C /home/rhythm 
find /home/rhythm/home_rhythm/.[!.]* -exec mv {} /home/rhythm/ \; # move dotfiles
find /home/rhythm/home_rhythm/* -exec mv {} /home/rhythm/ \; # move rest of files
rmdir /home/rhythm/home_rhythm
