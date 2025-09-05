use strict;
use warnings;

# -------------------------------
# Глобальные переменные
# -------------------------------

# Указатель (ссылка) на начало связного списка студентов.
# Связный список хранит данные в виде хешей, где есть поле NEXT.
my $head;

# Ограничения для годов рождения (можно менять при необходимости)
my $MAX_YEAR = 2025;
my $MIN_YEAR = 1900;

# -------------------------------
# Главное меню
# -------------------------------
while (1) {
    print "\nМеню:\n";
    print "1. Добавить студента\n";
    print "2. Удалить студента (по номеру зачетной книжки)\n";
    print "3. Вывести список студентов\n";
    print "4. Выход\n";
    print "Ваш выбор: ";

    chomp( my $choice = <> // '' );  # читаем ввод
    $choice = trim($choice);         # убираем пробелы по краям

    if ($choice eq '1') {
        # --- Добавление студента ---
        my $fio   = read_nonempty("ФИО: ");
        my $zach  = read_nonempty("№ зачетной книжки (ключ): ");
        my $group = read_nonempty("№ группы: ");
        my $spec  = read_nonempty("Специальность: ");
        my $date  = read_date();  # ввод даты рождения с проверкой

        # Создаем хеш студента (ключ-значение).
        # NEXT = undef, так как он пока не связан со следующим.
        my %student = (
            FIO   => $fio,
            ZACH  => $zach,
            GROUP => $group,
            SPEC  => $spec,
            DOB   => $date,
            NEXT  => undef,
        );

        # Пытаемся вставить в список
        if ( insert(\$head, \%student) ) {
            print "Студент добавлен.\n";
        } else {
            print "Студент не добавлен (дублирование ключа).\n";
        }
    }
    elsif ($choice eq '2') {
        # --- Удаление студента ---
        print "Введите № зачетной книжки для удаления: ";
        chomp( my $zach = <> // '' );
        $zach = trim($zach);

        if ($zach eq '') {
            print "Пустой ключ — отмена.\n";
        } else {
            if ( delete_node(\$head, $zach, undef) ) {
                print "Студент с № $zach удалён.\n";
            } else {
                print "Студент с № $zach не найден.\n";
            }
        }
    }
    elsif ($choice eq '3') {
        # --- Печать всех студентов ---
        print "\nСписок студентов:\n";
        list_print($head);
    }
    elsif ($choice eq '4') {
        last; # выход из цикла while(1)
    }
    else {
        print "Неверный выбор!\n";
    }
}

# -------------------------------
# Вспомогательные функции
# -------------------------------

# trim($s) — удаляет пробелы и табы в начале и конце строки.
# Заменяем регулярку на pos() и substr().
sub trim {
    my $s = shift // '';

    # убираем пробелы слева
    my $start = 0;
    while ($start < length($s) && substr($s, $start, 1) =~ /\s/) {
        $start++;
    }

    # убираем пробелы справа
    my $end = length($s) - 1;
    while ($end >= $start && substr($s, $end, 1) =~ /\s/) {
        $end--;
    }

    return substr($s, $start, $end - $start + 1);
}

# Ввод строки с проверкой, что она не пустая
sub read_nonempty {
    my ($prompt) = @_;
    while (1) {
        print $prompt;
        chomp( my $v = <> // '' );
        $v = trim($v);
        return $v if length $v;
        print "Поле не может быть пустым. Попробуйте ещё раз.\n";
    }
}

# Ввод даты с проверкой формата и диапазона
sub read_date {
    while (1) {
        print "Дата рождения (дд.мм.гггг): ";
        chomp( my $d = <> // '' );
        $d = trim($d);

        if ( validate_date($d) ) {
            return $d;
        } else {
            print "Неверная дата. Ожидается дд.мм.гггг (год $MIN_YEAR..$MAX_YEAR).\n";
        }
    }
}

# Проверка даты без регулярок
sub validate_date {
    my ($d) = @_;
    return 0 unless defined $d;

    # Должно быть ровно 10 символов: "dd.mm.yyyy"
    return 0 unless length($d) == 10;
    return 0 unless substr($d,2,1) eq '.' && substr($d,5,1) eq '.';

    # Разделим по точкам
    my @parts = split /\./, $d;
    return 0 unless @parts == 3;

    my ($dd, $mm, $yy) = @parts;
    return 0 unless $dd =~ /^\d+$/ && $mm =~ /^\d+$/ && $yy =~ /^\d+$/;

    $dd += 0; $mm += 0; $yy += 0; # приведение к числу

    return 0 if $yy < $MIN_YEAR || $yy > $MAX_YEAR;
    return 0 if $mm < 1 || $mm > 12;

    # Дни в месяцах
    my @mdays = (0,31,28,31,30,31,30,31,31,30,31,30,31);

    # Проверка на високосный год для февраля
    if ($mm == 2) {
        my $is_leap = ($yy % 400 == 0) || ($yy % 4 == 0 && $yy % 100 != 0);
        $mdays[2] = 29 if $is_leap;
    }

    return 0 if $dd < 1 || $dd > $mdays[$mm];
    return 1;
}

# -------------------------------
# Рекурсивные подпрограммы
# -------------------------------

# insert(\$head_or_next, \%student)
# Вставляет студента в связный список, упорядоченный по номеру зачетки (ZACH).
sub insert {
    my ($ref, $student) = @_;

    unless ($$ref) {
        # Если список пуст — создаём новый узел
        $$ref = { %$student, NEXT => undef };
        return 1;
    }

    # Сравнение ключей (номер зачетки), нечувствительно к регистру
    my $newk = lc $student->{ZACH} // '';
    my $curk = lc $$ref->{ZACH} // '';

    if ($newk eq $curk) {
        warn "Такой номер зачетной книжки уже есть!\n";
        return 0;
    }

    if ($newk lt $curk) {
        # Вставка перед текущим элементом
        my $new = { %$student, NEXT => $$ref };
        $$ref = $new;
        return 1;
    }

    # Рекурсивно вставляем дальше
    return insert(\($$ref->{NEXT}), $student);
}

# delete_node(\$head_or_next, $zach, $prev)
# Удаляет студента по номеру зачетки. Возвращает 1 если удалён.
sub delete_node {
    my ($ref, $zach, $prev) = @_;
    return 0 unless $$ref;

    if ( lc($$ref->{ZACH} // '') eq lc($zach // '') ) {
        if ($prev) {
            $prev->{NEXT} = $$ref->{NEXT}; # перепрыгиваем через текущий узел
        } else {
            $$ref = $$ref->{NEXT};         # удаляем голову списка
        }
        return 1;
    }

    return delete_node(\($$ref->{NEXT}), $zach, $$ref);
}

# list_print($node)
# Рекурсивная печать всех студентов
sub list_print {
    my ($item) = @_;
    return unless $item;

    printf "ФИО: %s, Зачетка: %s, Группа: %s, Спец: %s, ДР: %s\n",
        $item->{FIO}   // '',
        $item->{ZACH}  // '',
        $item->{GROUP} // '',
        $item->{SPEC}  // '',
        $item->{DOB}   // '';

    list_print($item->{NEXT}); # рекурсия
}
