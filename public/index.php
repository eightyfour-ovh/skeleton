<?php

use App\Kernel;
use Eightyfour\Core\DotEnv;
use Eightyfour\Core\Request\Request;

require_once dirname(__DIR__).'/vendor/autoload.php';
const __PROJECT__ = __DIR__ . '/../';
const __APP__ = __DIR__ . '/../src/';

(new DotEnv())->load(path: __PROJECT__ . '.env.local');
Kernel::boot(prod: DotEnv::isProd())
    ->handle(request: Request::createFromGlobals())
    ->terminate()
;
