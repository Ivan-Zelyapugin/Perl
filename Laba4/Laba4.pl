use lib '.';  
use CD;

my @collection;

sub create_cd {
    print "Введите название CD: ";
    chomp(my $title = <STDIN>);

    print "Введите имя исполнителя: ";
    chomp(my $artist = <STDIN>);

    print "Введите год выпуска: ";
    chomp(my $year = <STDIN>);

    print "Введите жанр: ";
    chomp(my $genre = <STDIN>);

    return new CD($title, $artist, $year, $genre);
}

sub insert_cd {
    my ($cd) = @_;
    my $index = 0;

     while ($index < @collection) {
        my $cmp = compare_two($collection[$index], $cd, "year");
        last if $cmp >= 0;
        $index++;
    }

    splice(@collection, $index, 0, $cd);
    print "CD вставлен в коллекцию на позицию $index.\n";
}

sub delete_cd {
    print "Введите индекс: ";
    chomp(my $i = <STDIN>);
    if ($i >= 0 && $i < @collection) {
        splice(@collection, $i, 1);
        print "Удалено.\n";
    } else {
        print "Неверный индекс.\n";
    }
}

sub compare_items {
    print "Введите индекс первого CD: ";
    chomp(my $i1 = <STDIN>);
    print "Введите индекс второго CD: ";
    chomp(my $i2 = <STDIN>);
    print "Введите поле для сравнения (title, artist, year, genre): ";
    chomp(my $f = <STDIN>);

    if ($i1 < 0 || $i1 >= @collection || $i2 < 0 || $i2 >= @collection) {
        print "Неверные индексы.\n";
        return;
    }

    my $res = compare_two($collection[$i1], $collection[$i2], $f);
    if ($res < 0) {
        print "CD $i1 < CD $i2 по полю '$f'.\n";
    } elsif ($res == 0) {
        print "CD $i1 = CD $i2 по полю '$f'.\n";
    } else {
        print "CD $i1 > CD $i2 по полю '$f'.\n";
    }
}

sub display_collection {
    if (!@collection) {
        print "Коллекция пуста.\n";
        return;
    }

    my @headers = ("#", "Название", "Исполнитель", "Год", "Жанр");
    my @lengths = (1, 7, 11, 3, 4);

    my @rows;
    for my $i (0 .. $#collection) {
        my @info = $collection[$i]->display_info();   
        my @row  = ($i, @info);
        push @rows, \@row;

        for my $j (0..$#row) {
            my $len = length($row[$j]);
            $lengths[$j] = $len if $len > $lengths[$j];
        }
    }

    my $fmt = join(" | ", map { "%-${_}s" } @lengths) . "\n";

    printf $fmt, @headers;
    my $total_len = 0;
    $total_len += $_ + 3 for @lengths;
    $total_len -= 3 if $total_len > 0;
    print "-" x $total_len, "\n";

    for my $row (@rows) {
        printf $fmt, @$row;
    }
}

while (1) {
    print "\nМеню:\n";
    print "1. Добавить новый CD\n";
    print "2. Удалить CD\n";
    print "3. Показать коллекцию\n";
    print "4. Сравнить два CD\n";  
    print "5. Выйти\n";
    print "Выберите действие: ";
    my $choice = <STDIN>;
    chomp($choice);

    if ($choice == 1) {
        my $cd = create_cd();
        insert_cd($cd);
    } elsif ($choice == 2) {
        delete_cd();
    } elsif ($choice == 3) {
        display_collection();
    } elsif ($choice == 4) {
        compare_items();  
    } elsif ($choice == 5) {
        last;
    } else {
        print "Неверный выбор. Попробуйте снова.\n";
    }
}
