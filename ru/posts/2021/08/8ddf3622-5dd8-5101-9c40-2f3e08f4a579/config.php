<?php

# Database.
$config['db']['host']                             = '127.0.0.1';
$config['db']['port']                             = 3306;
$config['db']['username']                         = '';
$config['db']['password']                         = '';
$config['db']['dbname']                           = '';
$config['db']['socket']                           = null;

# Unicode support.
$config['fullUnicode']                            = true;

# Site-wide feature.
$config['enableTfa']                              = false;
$config['enableApi']                              = false;
$config['enableOneClickUpgrade']                  = false;

# Cookie.
$config['cookie']['prefix']                       = 'xf_';

# Data and script locations.
$config['externalDataPath']                       = 'storage/data';
$config['externalDataUrl']                        = 'storage/data';
$config['internalDataPath']                       = 'storage/data.int';
$config['codeCachePath']                          = '%s/cache/code';
$config['tempDataPath']                           = '%s/temp';
$config['javaScriptUrl']                          = 'js';

# Auth.
$config['auth'] = [
  'algo' => PASSWORD_ARGON2ID
];

# Cache.
/*
$config['cache']['enabled']                       = true;
$config['cache']['provider']                      = 'Redis';
$config['cache']['config']                        = [
  'host' => '127.0.0.1',
  'password' => '',
  'database' => 1
];
*/

# Guest page caching.
/*
$config['pageCache']['enabled']                   = true;
$config['cache']['context']['page']['provider']   = 'Filesystem';
$config['cache']['context']['page']['config']     = [
  'directory' => ''
];
*/
