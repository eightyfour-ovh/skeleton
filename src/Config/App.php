<?php

namespace App\Config;

use Eightyfour\Attribute\Config as Cfg;
use Eightyfour\Configuration\Configurator;
use Eightyfour\Exception\AuthenticatorException;
use Eightyfour\Exception\ProviderException;
use Eightyfour\Security\Auth\Authenticator as DefaultAuthenticator;
use Eightyfour\Security\Auth\Provider as DefaultProvider;

#[Cfg\Router(directories: [
    'Controller/',
])]
#[Cfg\Security(
    enabled: true,
    auth: new Cfg\Authentication(
        enabled: true,
        provider: new Cfg\Auth\Provider(
            enabled: true,
            providers: [
                DefaultProvider::class,
            ],
            default: DefaultProvider::class,
            exceptionType: ProviderException::class
        ),
        authenticator: new Cfg\Auth\Authenticator(
            enabled: true,
            authenticators: [
                DefaultAuthenticator::class,
            ],
            default: DefaultAuthenticator::class,
            fields: new Cfg\Auth\Fields(
                login: 'email',
                password: 'pass',
            ),
            exceptionType: AuthenticatorException::class
        ),
    ),
)]
class App extends Configurator
{
}