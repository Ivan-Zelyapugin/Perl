#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;

my $server_port = 8080;

# Создаем TCP сервер домена Internet
my $server = IO::Socket::INET->new(
    LocalPort => $server_port,
    Type      => SOCK_STREAM,
    Reuse     => 1,
    Listen    => 10
) or die "Не удалось создать сервер: $!";

print "Сервер TCP домена INTERNET запущен на порту $server_port...\n";

while (1) {
    # Ждем подключения клиента
    my $client = $server->accept();
    print "Клиент подключен.\n";

    # Прием сообщений от клиента
    while (defined(my $message = <$client>)) {
        chomp $message;
        print "Входящее сообщение: $message\n";

        # Инвертируем строку
        my $inverted = reverse $message;

        # Отправляем обратно клиенту
        print $client "$inverted\n";
        print "Отправлено инвертированное сообщение: $inverted\n";
    }

    print "Клиент отключен.\n";
    close($client);
}

close($server);
