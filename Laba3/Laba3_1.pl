use strict;
use warnings;

# Указатель на голову списка
my $head;

# Текущее максимальное допустимое год (можно менять)
my $MAX_YEAR = 2025;
my $MIN_YEAR = 1900;

while (1) {
    print "\nМеню:\n";
    print "1. Добавить студента\n";
    print "2. Удалить студента (по номеру зачетной книжки)\n";
    print "3. Вывести список студентов\n";
    print "4. Выход\n";
    print "Ваш выбор: ";
    chomp( my $choice = <> // '' );
    $choice =~ s/^\s+|\s+$//g;

    if ($choice eq '1') {
        my $fio   = read_nonempty("ФИО: ");
        my $zach  = read_nonempty("№ зачетной книжки (ключ): ");
        my $group = read_nonempty("№ группы: ");
        my $spec  = read_nonempty("Специальность: ");
        my $date  = read_date();

        my %student = (
            FIO  => $fio,
            ZACH => $zach,
            GROUP => $group,
            SPEC => $spec,
            DOB  => $date,   # дата рождения
            NEXT => undef,
        );

        if ( insert(\$head, \%student) ) {
            print "Студент добавлен.\n";
        } else {
            print "Студент не добавлен (возможно, дублирование ключа).\n";
        }
    }
    elsif ($choice eq '2') {
        print "Введите № зачетной книжки для удаления: ";
        chomp( my $zach = <> // '' );
        $zach =~ s/^\s+|\s+$//g;
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
        print "\nСписок студентов:\n";
        list_print($head);
    }
    elsif ($choice eq '4') {
        last;
    }
    else {
        print "Неверный выбор!\n";
    }
}

# ------------------------
# Вспомогательные подпрограммы
# ------------------------

sub trim { my $s = shift // ''; $s =~ s/^\s+|\s+$//g; return $s; }

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

sub read_date {
    while (1) {
        print "Дата рождения (дд.мм.гггг): ";
        chomp( my $d = <> // '' );
        $d = trim($d);
        if ( validate_date($d) ) {
            return $d;
        } else {
            print "Неверная дата. Ожидается корректная дата в формате дд.мм.гггг (год $MIN_YEAR..$MAX_YEAR).\n";
        }
    }
}

sub validate_date {
    my ($d) = @_;
    return 0 unless defined $d;
    return 0 unless $d =~ /^(\d{2})\.(\d{2})\.(\d{4})$/;
    my ($dd, $mm, $yy) = ($1+0, $2+0, $3+0);

    return 0 if $yy < $MIN_YEAR || $yy > $MAX_YEAR;
    return 0 if $mm < 1 || $mm > 12;

    my @mdays = (0,31,28,31,30,31,30,31,31,30,31,30,31);
    # високосный год
    if ( $mm == 2 ) {
        my $is_leap = ($yy % 4 == 0);
        $mdays[2] = 29 if $is_leap;
    }
    return 0 if $dd < 1 || $dd > $mdays[$mm];
    return 1;
}

# =======================
# Рекурсивные подпрограммы
# =======================

# insert(\$head_or_next, \%student)
# Вставляет элемент в список, упорядоченный по ZACH (строковое, нечувствительное к регистру)
# Возвращает 1 при успешной вставке, 0 при дубликате
sub insert {
    my ($ref, $student) = @_;
    unless ($$ref) {
        # создаём узел; NEXT обязательно определён
        $$ref = { %$student, NEXT => undef };
        return 1;
    }

    my $newk = lc $student->{ZACH} // '';
    my $curk = lc $$ref->{ZACH} // '';

    if ($newk eq $curk) {
        warn "Такой номер зачетной книжки уже есть!\n";
        return 0;
    }

    if ($newk lt $curk) {
        my $new = { %$student, NEXT => $$ref };
        $$ref = $new;
        return 1;
    }

    return insert(\($$ref->{NEXT}), $student);
}

# delete_node(\$head_or_next, $zach, $prev_hashref)
# Возвращает 1 если удалил, 0 если не найден
sub delete_node {
    my ($ref, $zach, $prev) = @_;
    return 0 unless $$ref;

    if ( lc($$ref->{ZACH} // '') eq lc($zach // '') ) {
        if ($prev) {
            # prev — это хеш-реф текущего предыдущего узла
            $prev->{NEXT} = $$ref->{NEXT};
        } else {
            # удаляем голову
            $$ref = $$ref->{NEXT};
        }
        return 1;
    }

    return delete_node(\($$ref->{NEXT}), $zach, $$ref);
}

# list_print($node_hashref)
sub list_print {
    my ($item) = @_;
    return unless $item;

    printf "ФИО: %s, Зачетка: %s, Группа: %s, Спец: %s, ДР: %s\n",
        $item->{FIO} // '',
        $item->{ZACH} // '',
        $item->{GROUP} // '',
        $item->{SPEC} // '',
        $item->{DOB} // '';

    list_print($item->{NEXT});
}
