use strict;
use warnings;
use utf8;                       # исходный код в UTF-8
binmode STDOUT, ':encoding(UTF-8)';  # вывод в UTF-8

my $title      = "Пример страницы";
my $heading    = "Простейшая HTML-страница, сгенерированная на Perl";
my $gruppa     = "Выполнили студенты группы 22ВП2:";
my $students_1 = "Зеляпугин";
my $students_2 = "Зиновьев";
my $students_3 = "Сафронов";
my $students_4 = "Каледа";

print <<"HTML";
<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; }
    header { border-bottom: 1px solid #ddd; padding-bottom: 0.5rem; margin-bottom: 1rem }
  </style>
</head>
<body>
  <header>
    <h1>$heading</h1>
  </header>
  <main>
    <p>$gruppa</p>
    <ul>
      <li>$students_1</li>
      <li>$students_2</li>
      <li>$students_3</li>
      <li>$students_4</li>
    </ul>
  </main>
</body>
</html>
HTML
