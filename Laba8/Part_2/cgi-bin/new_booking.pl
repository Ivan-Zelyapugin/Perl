#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $cgi = CGI->new;

# Открываем файл с доступными номерами
my $rooms_file = "/home/sansetto/Perl/Laba8/Part_2/data/rooms.txt";
open(my $rfh, '<', $rooms_file) or die "Could not open file '$rooms_file' $!";
my %available_rooms;

# Чтение номеров из файла
while (my $line = <$rfh>) {
    chomp $line;
    my ($type, $rooms) = split(':', $line);
    my @rooms = split(',', $rooms);
    $available_rooms{$type} = scalar @rooms > 0 ? \@rooms : [];
}
close $rfh;

# Формируем форму для бронирования
print $cgi->header(-type => 'text/html', -charset => 'UTF-8');
print $cgi->start_html('Новая бронь');
print $cgi->h1('Забронировать номер');

print $cgi->start_form(-method => 'POST', -action => '/cgi-bin/confirm_booking.pl');

# Поле для ввода имени
print $cgi->label('Имя: '); 
print $cgi->textfield(-name => 'name'); 
print $cgi->br;

# Поле для выбора типа номера
print $cgi->label('Тип номера: ');

# Генерация списка типов номеров, где есть доступные номера
my @room_types = grep { @{$available_rooms{$_}} > 0 } keys %available_rooms;
if (@room_types) {
    print $cgi->popup_menu(
        -name   => 'room_type',  # Имя должно совпадать с параметром в confirm_booking.pl
        -values => \@room_types,
    );
} else {
    print "<p>Нет доступных номеров для бронирования.</p>";
}

print $cgi->br;

# Кнопка для подтверждения
print $cgi->submit(-value => 'Подтвердить бронь'); 
print $cgi->end_form;

print $cgi->end_html;