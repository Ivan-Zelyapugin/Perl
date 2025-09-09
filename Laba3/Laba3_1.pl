use strict;
use warnings;

my $head;  # указатель (ссылка) на начало связного списка студентов
my $MAX_YEAR = 2025;  # верхняя граница допустимого года рождения
my $MIN_YEAR = 1900;  # нижняя граница допустимого года рождения

while (1) {
    print "\nМеню:\n";
    print "1. Добавить студента\n";
    print "2. Удалить студента (по номеру зачетной книжки)\n";
    print "3. Вывести список студентов\n";
    print "4. Выход\n";
    print "Ваш выбор: ";

    chomp( my $choice = <>);  # читаем ввод пользователя

    if ($choice eq '1') {
        # --- Добавление студента ---
        # Считываем поля студента с проверкой на пустоту
        my $fio   = read_nonempty("ФИО: ");
        my $zach  = read_nonempty("№ зачетной книжки (ключ): ");
        my $group = read_nonempty("№ группы: ");
        my $spec  = read_nonempty("Специальность: ");
        my $date  = read_date();  # ввод даты рождения с проверкой

        # Создаем хеш для студента (анонимный хеш для хранения данных)
        my %student = (
            FIO   => $fio,
            ZACH  => $zach,
            GROUP => $group,
            SPEC  => $spec,
            DOB   => $date,
            NEXT  => undef,  # пока не связан с другим элементом
        );

        # Вставляем студента в упорядоченный список
        if ( insert(\$head, \%student) ) {
            print "Студент добавлен.\n";
        } else {
            print "Студент не добавлен (дублирование ключа).\n";
        }
    }
    elsif ($choice eq '2') {
        # --- Удаление студента ---
        print "Введите № зачетной книжки для удаления: ";
        chomp( my $zach = <>);

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
        list_print_all($head);  # вывод таблицы студентов
    }
    elsif ($choice eq '4') {
        last;  # выход из программы
    }
    else {
        print "Неверный выбор!\n";
    }
}

# read_nonempty($prompt) — считывает непустую строку с проверкой
sub read_nonempty {
    my ($prompt) = @_;
    while (1) {
        print $prompt;
        chomp( my $v = <>);
        return $v if length $v;  # возвращаем значение, если не пустое
        print "Поле не может быть пустым. Попробуйте ещё раз.\n";
    }
}

# read_date() — считывает дату рождения с проверкой формата и диапазона
sub read_date {
    while (1) {
        print "Дата рождения (дд.мм.гггг): ";
        chomp( my $d = <> );
        if ( validate_date($d) ) {
            return $d;  # дата валидна
        } else {
            print "Неверная дата. Ожидается дд.мм.гггг (год $MIN_YEAR..$MAX_YEAR).\n";
        }
    }
}

# validate_date($d) — проверка даты на корректность
sub validate_date {
    my ($d) = @_;
    return 0 unless defined $d;               # проверка на undef
    return 0 unless length($d) == 10;         # должно быть ровно 10 символов
    return 0 unless $d =~ /^\d{2}\.\d{2}\.\d{4}$/;  # формат дд.мм.гггг

    my ($dd, $mm, $yy) = split /\./, $d;
    $dd += 0; $mm += 0; $yy += 0;             # приведение к числу

    # проверка диапазонов
    return 0 if $yy < $MIN_YEAR || $yy > $MAX_YEAR;
    return 0 if $mm < 1 || $mm > 12;

    return 1;  # дата корректна
}

# -------------------------------
# Рекурсивные подпрограммы для работы со списком
# -------------------------------

# insert(\$head_or_next, \%student)
# Вставляет студента в упорядоченный список по ключу ZACH
sub insert {
    my ($ref, $student) = @_;
    unless ($$ref) {
        # Если узел пуст, создаём новый
        $$ref = { %$student, NEXT => undef };
        return 1;
    }
    my $newk = lc $student->{ZACH} // '';  # ключ нового элемента
    my $curk = lc $$ref->{ZACH} // '';     # ключ текущего элемента

    if ($newk eq $curk) {
        warn "Такой номер зачетной книжки уже есть!\n";
        return 0;
    }
    if ($newk lt $curk) {
        # вставка перед текущим элементом
        my $new = { %$student, NEXT => $$ref };
        $$ref = $new;
        return 1;
    }
    # рекурсивная вставка в следующий элемент
    return insert(\($$ref->{NEXT}), $student);
}

# delete_node(\$head_or_next, $zach, $prev)
# Удаляет студента по номеру зачетки
sub delete_node {
    my ($ref, $zach, $prev) = @_;
    return 0 unless $$ref;  # если узел пуст — ничего не делаем

    if ( lc($$ref->{ZACH} // '') eq lc($zach // '') ) {
        # если совпадает ключ
        if ($prev) {
            $prev->{NEXT} = $$ref->{NEXT};  # перепрыгиваем через текущий элемент
        } else {
            $$ref = $$ref->{NEXT};          # удаляем голову списка
        }
        return 1;  # удаление выполнено
    }
    # рекурсивная проверка следующего узла
    return delete_node(\($$ref->{NEXT}), $zach, $$ref);
}

# list_print_all($head) — вывод всего списка в виде таблицы
sub list_print_all {
    my ($head) = @_;
    unless ($head) {
        print "Список пуст.\n";
        return;
    }

    # заголовки столбцов
    my @headers = ("ФИО", "Зачетка", "Группа", "Специальность", "Дата рожд.");
    my @lengths = (3, 7, 6, 12, 10);  # минимальная ширина

    # собираем строки данных и определяем максимальную ширину колонок
    my @rows;
    my $node = $head;
    while ($node) {
        my @row = (
            $node->{FIO},
            $node->{ZACH},
            $node->{GROUP},
            $node->{SPEC},
            $node->{DOB},
        );
        push @rows, \@row;

        # обновляем максимальную ширину каждой колонки
        for my $i (0..4) {
            my $len = length($row[$i]);
            $lengths[$i] = $len if $len > $lengths[$i];
        }
        $node = $node->{NEXT};
    }

    # формируем форматную строку для printf
    my $fmt = join(" | ", map { "%-${_}s" } @lengths) . "\n";

    # вывод заголовка таблицы
    printf $fmt, @headers;

    # вывод разделителя
    my $total_len = 0;
    $total_len += $_ + 3 for @lengths;  # учитываем " | "
    $total_len -= 3 if $total_len > 0;  # убираем лишние символы
    print "-" x $total_len, "\n";

    # вывод всех строк данных
    for my $row (@rows) {
        printf $fmt, @$row;
    }
}
