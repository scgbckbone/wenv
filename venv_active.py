#!/usr/bin/env python

import sys

return_code = 0 if hasattr(sys, 'real_prefix') else 1
sys.exit(return_code)
