The Xing Framework: Root
===

[![Code Climate](https://codeclimate.com/github/XingFramework/xing-root/badges/gpa.svg)](https://codeclimate.com/github/XingFramework/xing-root)
[![Test Coverage](https://codeclimate.com/github/XingFramework/xing-root/badges/coverage.svg)](https://codeclimate.com/github/XingFramework/xing-root/coverage)
[![Build Status](https://travis-ci.org/XingFramework/xing-root.svg?branch=master)](https://travis-ci.org/XingFramework/xing-root)
[![Dependency Status](https://gemnasium.com/XingFramework/xing-root.svg)](https://gemnasium.com/XingFramework/xing-root)


The Xing Framework is a cutting edge web and mobile development platform by
Logical Reality Design, Inc.  It is designed to provide a completely modern
(and even somewhat future-proofed) API + SPA web development platform with
sensible defaults, solid conventions, and ease of rapid development. Xing uses
Rails (4.2) on the backend and AngularJS (1.4) on the frontend.  Most of the
problems inherent in getting these two frameworks to talk to each other cleanly
have been pre-solved in Xing.

This gem contains all the Ruby rake tasks and other build tools 

Filesystem Architecture
-----------------------

A Xing project must have these three directories:

```
/          # Root - contains the application
/backend   # Backend contains the Rails application and its tests
/frontend  # Frontend contains the AngularJS application and its tests
```

Each of these three will have a different Gemfile for Ruby dependencies.  This gem, xing-root,
must be in the gemfile in the root directory ```/``` of the application.

Main tools
----------

* ```rake develop```  Builds a Xing project, starts servers, and launches it in a browser.
* ```rake spec``` Runs both front- and back-end tests as well as E2E tests. 

Additional info TBD.

Authors
-------

* Judson Lester
* Patricia Ho

Version
-------

Untagged version, not yet ready for release
    

