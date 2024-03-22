<?php

namespace App\Controller;

use Eightyfour\Attribute\Router\Route;
use Eightyfour\Core\Response\Result;

#[Route(path: '/', name: 'app_index_')]
class IndexController extends BaseController
{
    #[Route(path: '', name: 'home', methods: ['GET', 'POST'])]
    public function home(): Result
    {
        return new Result(data: ['result' => 'OK']);
    }
}