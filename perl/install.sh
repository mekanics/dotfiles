#!/bin/bash

brew install perl

eval "$(perl -I$HOME/.perl5/lib/perl5 -Mlocal::lib=$HOME/.perl5)"
PERL_MM_OPT="INSTALL_BASE=$HOME/.perl5" cpan local::lib
