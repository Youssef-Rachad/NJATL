#!/usr/bin/perl
use strict;
use warnings; # Good to have
use Time::Piece; # Date and Time Formatting

print localtime->strftime('%Y%m%d');
