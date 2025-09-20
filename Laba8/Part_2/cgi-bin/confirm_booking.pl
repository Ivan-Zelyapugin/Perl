#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Fcntl qw(:flock);

my $cgi = CGI->new;
my $name = $cgi->param('name');
my $room_type = $cgi->param('room_type');

# Открываем файл с доступными номерами
my $rooms_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms.txt";
open(my $rfh, '<', $rooms_file) or die "Could not open file '$rooms_file' $!";
my %available_rooms;

# Чтение номеров из файла
while (my $line = <$rfh>) {
    chomp $line;
    my ($type, $rooms) = split(':', $line);
    $available_rooms{$type} = [split(',', $rooms)];
}
close $rfh;

# Проверяем, есть ли свободные номера для выбранного типа
if (!@{$available_rooms{$room_type}}) {
    print $cgi->header(-type => 'text/html', -charset => 'UTF-8');
    print $cgi->start_html('Ошибка');
    print $cgi->h1("Нет доступных номеров для типа $room_type.");
    print $cgi->a({-href => '/cgi-bin/new_booking.pl'}, 'Назад к бронированию');
    print $cgi->end_html;
    exit;
}

# Выбираем первый доступный номер
my $room_number = shift @{$available_rooms{$room_type}};

# Обновляем файл номеров
open(my $wfh, '>', $rooms_file) or die "Could not open file '$rooms_file' $!";
flock($wfh, LOCK_EX);
foreach my $type (keys %available_rooms) {
    print $wfh "$type:" . join(',', @{$available_rooms{$type}}) . "\n";
}
flock($wfh, LOCK_UN);
close $wfh;

# Записываем бронирование в файл
my $bookings_file = "/home/sansetto/Perl/Laba8/Part_2/data/bookings.txt";
open(my $bfh, '>>', $bookings_file) or die "Could not open file '$bookings_file' $!";
flock($bfh, LOCK_EX);
print $bfh "$name забронировал номер $room_number ($room_type)\n";
flock($bfh, LOCK_UN);
close $bfh;

# Вывод подтверждения
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');
print $cgi->start_html('Бронь подтверждена');
print $cgi->h1('Спасибо!');
print $cgi->p("Вы забронировали номер $room_number ($room_type).");
print $cgi->p("На имя: $name");
print $cgi->a({-href => '/cgi-bin/new_booking.pl'}, 'Забронировать еще один номер');
print $cgi->a({-href => '/index.html'}, 'На главную');
print $cgi->end_html;