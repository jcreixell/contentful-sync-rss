Contentful RSS Sync
===================

[![Build Status](https://travis-ci.org/jcreixell/contentful-sync-rss.png?branch=master)](https://travis-ci.org/jcreixell/contentful-sync-rss)

RSS proxy for Contentful Synchronization API

Setup
-----

    git clone git://github.com/jcreixell/contentful-rss-sync.git
    cd contentful-rss-sync

Requirements
------------

* Redis

Usage
-----

Run the server:

    ruby runner.rb -s -c config.rb

Create some clients:

    redis-cli
    > set clients:XXXXXX:access_token 300f33c4a33b9c23dd9ab810bd297929
    > set clients:XXXXXX:space cfexampleapi

Example request:

    curl -H "Client-Id: XXXXXX" -X GET http://0.0.0.0:9000/

License
-------

Contentful RSS Sync is free software, and may be redistributed under the terms
specified in the MIT-LICENSE file.
