#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use utf8;  # позволяет писать UTF-8 в коде

# Получаем параметры
my $user = param('regname');
my $skin = param('skin');
my $hair = param('hair');

# Проверка имени
if (!$user) {
    print redirect('/back.html');
    exit;
}

# Определяем цветовой тип
my $type;
if ($hair eq 'redish') {
    $type = 'automn';
}
elsif ($skin eq 'rose' && $hair eq 'golden_blonde') {
    $type = 'spring';
}
elsif (($hair eq 'black' || $hair eq 'darkbrown') && ($skin eq 'pale' || $skin eq 'dark')) {
    $type = 'winter';
}
else {
    $type = 'summer';
}

# Генерация HTML
print header(-type => 'text/html', -charset => 'utf-8');
print start_html(
    -title => "Результаты тестирования",
    -encoding => 'utf-8'
);
print h2("Привет, $user!");
print p("Ваш цветовой тип - $type");
print img({-src => "/images/$type.png", -align => "LEFT"});
print end_html;
