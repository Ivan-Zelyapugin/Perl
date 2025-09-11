use File::Spec;

print "Введите исходный каталог: ";
chomp(my $src = <STDIN>);
print "Введите каталог назначения: ";
chomp(my $dst = <STDIN>);

die "Исходный каталог $src не существует!\n" unless -d $src;
die "Каталог назначения $dst не существует!\n" unless -d $dst;

# имя исходной папки (например Laba1)
# .* = «любая последовательность символов».
# / Это просто слэш, значит ищем последний слэш в строке.
# s!.*/!! Заменить всё от начала строки до последнего / включительно на пустоту.
# $строка =~ s/шаблон/замена/;
(my $folder_name = $src) =~ s!.*/!!;

# полный путь назначения (например /home/sansetto/Laba1)
my $dst_root = File::Spec->catdir($dst, $folder_name);

# Если там ещё нет такой папки — создаём её.
mkdir $dst_root unless -d $dst_root;

sub move_dir {
    my ($from, $to) = @_;

    opendir(my $dh, $from) or die "Не могу открыть $from: $!";
    my @entries = readdir($dh);
    closedir $dh;

    foreach my $entry (@entries) {
        next if $entry eq '.' or $entry eq '..';

        # $src_path — полный путь к текущему элементу в исходной папке, например /home/user/src/file.txt.
        my $src_path = File::Spec->catfile($from, $entry);

        # $dst_path — соответствующий путь в целевой папке, например /home/user/dest/file.txt.
        my $dst_path = File::Spec->catfile($to,   $entry);

        if (-d $src_path) {
            # mkdir $dst_path unless -d $dst_path; — создаёт целевую папку для этой поддиректории, если её ещё нет.
            mkdir $dst_path unless -d $dst_path;
            # move_dir($src_path, $dst_path); — рекурсивный вызов: переходим внутрь подкаталога и выполняем ту же логику (копирование/удаление всех его элементов).
            move_dir($src_path, $dst_path);
            # rmdir $src_path or warn ...; — пытаемся удалить исходную папку после того, как её содержимое перемещено
            rmdir $src_path or warn "Не удалось удалить каталог $src_path: $!\n";
        } else {
            # Открываем исходный файл для чтения (<) и создаём/открываем целевой файл для записи (>).
            open(my $in,  "<", $src_path)  or die "Не могу открыть $src_path: $!";
            open(my $out, ">", $dst_path)  or die "Не могу создать $dst_path: $!";

            # Переводит файловые дескрипторы в binary mode — важно для корректной работы с бинарными файлами
            binmode $in;
            binmode $out;

            # read($in, $buffer, 4096) читает до 4096 байт из входного файла в переменную $buffer.
            my $buffer;
            while (read($in, $buffer, 4096)) {
                print $out $buffer;
            }

            close $in;
            close $out;

            # unlink $src_path or warn "Не удалось удалить файл $src_path: $!\n";
            unlink $src_path or warn "Не удалось удалить файл $src_path: $!\n";
            print "Перемещён файл: $src_path → $dst_path\n";
        }
    }
}

# запускаем перемещение
move_dir($src, $dst_root);

# удаляем исходный каталог
rmdir $src or warn "Не удалось удалить каталог $src: $!\n";

print "\nКаталог успешно перемещён: $src → $dst_root\n";

# Запуск
# perl move_dir.pl