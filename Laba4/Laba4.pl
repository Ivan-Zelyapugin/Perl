use strict;
use warnings;
use lib '.';   # ищем модуль в текущей папке
use CD;

my @collection;

# ==============================
# Создание CD (возвращает объект)
# ==============================
sub create_cd {
    print "Введите название CD: ";
    my $title = <STDIN>;
    chomp($title);

    print "Введите имя исполнителя: ";
    my $artist = <STDIN>;
    chomp($artist);

    print "Введите год выпуска: ";
    my $year = <STDIN>;
    chomp($year);

    print "Введите жанр: ";
    my $genre = <STDIN>;
    chomp($genre);

    my $cd = CD->new(
        title  => $title,
        artist => $artist,
        year   => $year,
        genre  => $genre
    );

    return $cd;
}

# ==============================
# Вставка CD с сортировкой по году
# ==============================
sub insert_cd {
    my ($cd) = @_;
    my $index = 0;

    while ($index < @collection && $collection[$index]->compare($cd, 'year') == -1) {
        $index++;
    }

    splice(@collection, $index, 0, $cd);
    print "CD вставлен в коллекцию на позицию $index.\n";
}

# ==============================
# Обновление CD
# ==============================
sub update_cd {
    print "Введите индекс CD для обновления (начиная с 0): ";
    my $index = <STDIN>;
    chomp($index);

    if ($index >= 0 && $index < @collection) {
        my $cd = $collection[$index];

        print "Введите новое название (или Enter для пропуска): ";
        my $title = <STDIN>;
        chomp($title);

        print "Введите нового исполнителя (или Enter для пропуска): ";
        my $artist = <STDIN>;
        chomp($artist);

        print "Введите новый год выпуска (или Enter для пропуска): ";
        my $year = <STDIN>;
        chomp($year);

        print "Введите новый жанр (или Enter для пропуска): ";
        my $genre = <STDIN>;
        chomp($genre);

        $cd->update_info(
            title  => $title  ? $title  : undef,
            artist => $artist ? $artist : undef,
            year   => $year   ? $year   : undef,
            genre  => $genre  ? $genre  : undef
        );

        print "CD обновлён.\n";
    } else {
        print "Неверный индекс.\n";
    }
}

# ==============================
# Удаление CD
# ==============================
sub delete_cd {
    print "Введите индекс CD для удаления: ";
    my $index = <STDIN>;
    chomp($index);

    if ($index >= 0 && $index < @collection) {
        splice(@collection, $index, 1);
        print "CD удалён.\n";
    } else {
        print "Неверный индекс.\n";
    }
}

# ==============================
# Печать коллекции в виде таблицы
# ==============================
sub display_collection {
    if (!@collection) {
        print "Коллекция пуста.\n";
        return;
    }

    my @headers = ("#", "Название", "Исполнитель", "Год", "Жанр");
    my @lengths = (1, 7, 11, 3, 4); # минимальные ширины

    my @rows;
    for my $i (0 .. $#collection) {
        my $cd = $collection[$i];
        my @row = (
            $i,
            $cd->{title},
            $cd->{artist},
            $cd->{year},
            $cd->{genre}
        );
        push @rows, \@row;

        # обновляем ширину
        for my $j (0..$#row) {
            my $len = length($row[$j]);
            $lengths[$j] = $len if $len > $lengths[$j];
        }
    }

    # форматная строка
    my $fmt = join(" | ", map { "%-${_}s" } @lengths) . "\n";

    # заголовок
    printf $fmt, @headers;

    # разделитель
    my $total_len = 0;
    $total_len += $_ + 3 for @lengths;
    $total_len -= 3 if $total_len > 0;
    print "-" x $total_len, "\n";

    # строки
    for my $row (@rows) {
        printf $fmt, @$row;
    }
}

# ==============================
# Главное меню
# ==============================
while (1) {
    print "\nМеню:\n";
    print "1. Добавить новый CD\n";
    print "2. Обновить CD\n";
    print "3. Удалить CD\n";
    print "4. Показать коллекцию\n";
    print "5. Выйти\n";
    print "Выберите действие: ";
    my $choice = <STDIN>;
    chomp($choice);

    if ($choice == 1) {
        my $cd = create_cd();
        insert_cd($cd);
    } elsif ($choice == 2) {
        update_cd();
    } elsif ($choice == 3) {
        delete_cd();
    } elsif ($choice == 4) {
        display_collection();
    } elsif ($choice == 5) {
        last;
    } else {
        print "Неверный выбор. Попробуйте снова.\n";
    }
}
