#!/usr/bin/env perl
# 仔细的检查你的程序，避免出现简单的问题导致的错误
# print "Loading...\n";
# $_ = "ABC is American Born in China.\n";
# if (/\p{Space}/) {
	# print "The string has some whitespace.\n";
# }
# $_ = "0x31  0x20";
# if (/\p{Hex}\p{Hex}/) {
	# print "The string has a pair of hex digits.\n";
# }
# $_  = 'a real \\ backlash';
# if(/\\/){
	# print "It matched!\n";
# }
# $_ = "abba";
# if (/(.)\1/) {
	# print "It matched same character next to itself!\n";
# }
# 匹配类似abba这种回文模式，使用了反向引用技术
# $_ = "yabba dabba doo";
# if (/y(.)(.)\2\1/){
	# print "It matched after the y!\n";
# }
# $_ = "aa11bb";
# if (/(.)\111/){
	# print "It matched!\n";
# }
# use 5.010;
# $_ = "aa11bb";
# if (/(.)\g{1}11/) {
	# print "It matched!\n";
# }
# $_ = "xaa11bb";
# if (/(.)(.)\g{-1}11/) {
	# print "It matched!\n";
# }
# $_ = "The HAL-9000 requires authorization to continue.";
# if (/HAL-[0-9]+/) {
	# print "The string mentions some model of HAL computer.\n";
# }
# use 5.014;
# $_ = "The HAL-9000 requires authorization to continue.";
# if(/HAL-[\d]+/a){
	# say 'say:The string mentions some model of HAL computer.';
# }
# use 5.010;
# $_ = "The HAL-9000 requires authorization to continue.";
# if(/\s/a){
	# say 'The string matched ASCII whitespace.';
# }elsif(/\h/){
	# say 'The string matched some horizontal whitespace.';
# }elsif(/\v/){
	# say 'The string matched some vertical whitespace.';
# }elsif(/[\v\h]/){#等同于\p{Space},但比\s能匹配的要多
	# say 'The string matched some whitespace.';
# }
#/a 表示接受ascii中的字符集,/i表示进行大小写无关的匹配等，这些表示模式匹配修饰符号,/s能匹配包括换行符在内的任意字符,修饰符/s会把模式中出现的所有.都修改成能匹配到的任意字符，那么要是我们只想其中几个点号匹配任意字符呢?可以换用字符集[^\n],从5.12开始，perl引入了[\N]来表达\n的否定意义,/x允许我们在模式里随意加上空白符，由于加上/x后模式里可以随意插入空白，所以原来的表示空格和制表符本身的空白就失去了意义，perl会直接忽略，但是我们总是可以通过转义方式来变通实现，比如在空格前面加上反斜线或者使用\t等。perl还会把模式总出现的注释当作空白符直接忽略，所以我们居然可以在模式中添加注释，这也太不可思议了,注释部分不能使用定界符,否则会被视作模式终点,如果需要对单次匹配使用多项修饰符，只需要把它们一起写在模式末尾（不用在意先后顺序）/a/u/l分别表示了acsii、unicode、local,单个/a修饰符表示按照ASCII方式解释简写意义，如果使用两个/a则进一步表示仅仅采取ASCII方式的大小写映射处理
# /
# -?     #一个可有可无的减号
# [0-9]+ #小数点前必须出现一个或者多个数字
# \.?    #一个可有可无的小数点
# [0-9]* #小数点后面的数字，有没有都没有关系
# /x	 #字符串末尾
#注意一下perl中的流控语句的写法什么样的，这里不是用典型的else fi 或者elif，而是使用了elsif
#/[\dA-Fa-f]+/可以用来匹配十六进制数字，复合字符集[\d\D],可以用来匹配包括换行符在内的任意字符,字符'.'只能匹配到除换行符以外的任意字符,[^\d\D]，没错，这个字符集要表达的就是不匹配任何字符,就是这么任性
#OMG,更为灵活的是perl的正则表达式的定界符可以选择任意成对或者不成对的字符，只是当使用双斜线定界符'//'的时候可以不在patten的开头加注m,这里的m其实是表示matched，比如匹配网址的patten就可以写的很美观，m%^http://%，perl,你真是太灵活方便了
# print "Would you like to play a game?\n";
# chomp($_=<STDIN>);
# if (/yes/i){#这里进行大小写无关的匹配
	# print "In any case,I recommended that you go bowling.\n";
# }

# $_ = "I saw Barney\ndown at the bowling alley\nwith Fred\nlast night.\n";
# if(/Barney.*Fred/s){
	# print "That string mentions Fred after Barney!\n";
# }
# 来玩个高级的，对上面的说法进行一个综合运用

# if(m{#注意我们这里选用了定界符花括号，这里不能打出来，因为出现在pattern中的定界符将会被解释为pattern终止，
	# barney	#小伙子barney，看，这里居然可以换行
	# .*		#夹在中间的不管什么字符
	# fred	#大嗓门的fred
	# }six){	#同时使用了/s、/i和/x表示.能匹配换行符在内的任意字符,同时忽略模式中的大小写差异，同时忽略模式中的任意空白模式中的注释内容
	# print "advance:That string metions Fred after Barney!\n";
# }
#\A锚位匹配字符串的绝对开头，也就是说，如果开头位置匹配不上，是不会移到下一个位置继续尝试的，比如下面这个模式用于判断字符串是否以https开头m{\Ahttps?://}i,对应的，如果要匹配字符串的绝对末尾，可以用\z锚位。比如下面这条模式匹配以.png结果的字符串：m{\.png\z}i,需要强调的是，在\z后面再无任何其他东西。另外有个类似的行末锚位\Z,它允许后面出现换行符。这样人们就不用担心去掉单行末尾的换行符：，为了解决\A、\z和^、$之间差别，这个差别是在perl5之后引入的，如果不使用修饰符/m，那么上述两组锚位是同样的意义。但是加了/m修饰的^、$可以对多行字符串进行修饰。
# $_ = 'This is a wilma line
# barney is on another line
# but this ends in fred
# and a final dino line';
# if(/fred$/m){
	# print "fred is in end of line.\n";
# }
# if(/^barney/m){
	# print "barney is in begin of line.\n";
# }
# while(<STDIN>){
#	print if /\.png\Z/;
# }
#\b用来匹配单词边界，\B用来匹配非单词边界
#/stone\b/可以匹配standstone或者flintstone,但是不能匹配capstones
#/\bsearch\B会匹配searches,seaching与searched，但不匹配searche或researching
#默认情况下模式匹配的操作对象是$_，绑定操作符'=~'告诉perl，拿右边的模式来匹配左边的字符串，而不是匹配$_。
# my $some_other = "I dream of betty rubble.";
# if($some_other =~ /\brub/){
	# print "Aye,there's the rub.\n"; 
# }
# $_ = "I dream of betty rubble.";
# if(/\brub/){
	# print "different:Aye,there's the rub.\n";
# }
# print "Do you like perl?\n";
# 绑定操作符的优先级相当高，所以没有必要用圆括号来括住模式测试表达式
# my $like_perl = <STDIN> =~ /\byes\b/i;
# if($like_perl){
	# print "You said earlier that you like Perl,so...\n";
# }
#正则表达式内部可以进行双引号形式的内插，这样我们可以很快写出类似grep命令的程序
#!/usr/bin/env perl -w
#在这里，我想问一下，如何用perl创建文件，删除文件呢？估计是要用到前面的文件句柄的操作
#my $what = "larry";
#while(<>){
#	if(/\A($what)/){
#		print "We saw $what in beginning of $_";
#	}
#}

# my $dino = "I fear that I'll be extinct after 1000 years.";
# if($dino =~ /([0-9]*) years/){
	# print "That said '$1' years.\n"; #$1为1000
# }

# $dino = "I fear that I'll be extinct after a few million years.";
# if($dino =~ /([0-9]*)years/){
	# print "That said '$1' years.\n"; #$1为空字符串
# }

# my $wilma = '123';
# $wilma =~ /([0-9]+)/;
# if($wilma =~ /([a-zA-Z]+)/){
	# print "Wilma's word was $1.\n";
# }else{
	# print "Wilma doesn't have a word.\n";
# }
# use 5.010;
# my $names = 'Fred or Barney';
# if($names =~ m/(\w+) and (\w+)/){
    # say "I saw $1 and $2";#这里实际上看不到say的输出，因为模式字符串中期望的是
	# and 而变量实际给出的是or。为了让两者能够并存，此时应该采用的是择一匹配，不
	# 管是and还是or都没有关系。当然，作为则以匹配的一部分必须要加上圆括号以表示
	# 候选列表范围：
# }
use 5.010;
# my $names = 'Fred or Barney';
# if( $names =~ m/(\w+) (and|or) (\w+)/ ){#each word should split by white space.
    # say "I saw $1 and $2";
# }
#为了避免记忆$1之类的数字变量，Perl5.010增加了对捕获内容直接命名的写法。最终捕
#获到的内容会直接保存在特殊哈西%+里面，其中的键就是在捕获时使用的特殊标签，对应
#的值则是被捕获的字符串。举例：
# use 5.010;
# my $names = 'Fred or Barney';
# if( $names =~ m/(?<name1>\w+) (?:and|or) (?<name2>\w+)/){
    # say "I saw $+{name1} and $+{name2}";
# }
# 这里的name1和name2表示hash的键,也是标签
# use 5.010;
# my $names = 'Fred Flintstone and Wilma Flintstone';
# if($names =~ m/(?<last_name>\w+) and \w+ \g{last_name}/){
    # say "I saw $+{last_name}";
# }
#在以上的例子中，我们使用了\g{label}这样的写法：
#我们也可以用另一种用法来表示反向引用。\k<label>等效于\g{label}
# use 5.010;
# my $names = 'Fred flintstone and Wilma Flintstone';
# say "\\k的用法";
# if( $names =~ m/(?<last_name>\w+) and \w+ \K<last_name>/ ){
    # say "I saw $+{last_name}";
# }

# 介绍几个自动捕获变量，标点符号：$&、$`、$'
# if("Hello there, neighbor" =~ /\s(\w+),/){
    # print "That actually matched '$&'.\n";
# }
# if("Hello there, neighbor" =~ /\s(\w+),/){
    # print "That waw ($`)($&)($').\n";
# }
#这三个捕获变量符号虽然可以免费引用，不过，免费也是有代价的，在这里的代价是，一
#旦在程序的任何部分使用了某个自动捕获变量，其他正则表达式的运行速度也会变慢，所
#以，有些perl程序员就不会使用这些自动捕获变量
#如果使用的是5.010以上的版本，修饰符/p只会针对特定的正则表达式开启类似的自动捕
#获变量，但是他们的名字不再是那三个符号，取而代之的是用${^PREMATCH} ${^MATCH}
#{^ POSTMATCH}来表示
# $_ = "He's out bowling with Barney  tonight.";
# s/with (\w+)/against $1's team/;
# print "$_\n";
# m//表示match，即匹配模式，s///表示substitue，即替换模式
# use 5.014;
# my $original = 'Fred ate 1 rib';
# my $copy = $original;
# $copy =~ s/\d+ ribs?/10 ribs/;
# my $copy = $original =~ s!\d+ ribs?!10 ribs! r;
# 加上/r修饰符后，就会保留原来字符串变量中的值不变，而把替换结果作为替换操作的返
# 回值返回
# $_ = "I saw Barney with Fred.";
# s/(fred|barney)/\U$1/gi;
# \U 修饰符会将后面的所有字符串转成大写的,\L会转成小写的#\E会关闭大小写转换功能,
# 小写的\l、\u只会影响后面的第一个字符,这种用法不仅仅局限于替换时候，字符串内同样
# 也可以这样使用。这些用法也可以组合起来，如下面的例子
# print "Hello,\L\u$name\E,would you like to play a game?\n"
# split 操作符的用法如下：
# my @fields = split /separator/,$string;
# my @fields = split /:/,"abc:def:g:h";
# my @fields = split /:/,":::a:b:c:::"; #("",""<"",a,b,c)
# m默认split会以空白符分隔$_中的字符串
# my @fields = splits; #等效于split /\s+/,$_;
#与split的用法想法，join函数是把一些零碎的字符串整合起来，用法如下
#my $result = join $glue,@pieces;#join的第一参数是字符串
#列表至少要有两个元素，否则胶水无法涂进去
#下面的例子中有一对圆括号的模式会在每次匹配成功时返回一个捕获字符串：
# my $text = "Fred dropped a 5 ton granite block on Mr. Slate.";
# my @words = ($text =~ /([a-z]+)/ig);
# print "Result:@words\n";
# #假如我们想把一个字符串变成哈希，就可以这样做：
# my $data = "Barney Rubble Fred Flintstone Wilma Flintstone";
# my %last_name = ($data =~ /(\w+)\s+(\w+)/g);
# my $text = "Fred dropped a 5 ton granite block on Mr.Slate";
# my @words = ($text =~ /([a-z]+)/ig);
# print "Result: @words\n";
# $_ = "I thought you said Fred and <BOLD>Velma</BOLD>, not <BOLD>Wilma</BOLD>";
# s#/<BOLD>(.*?)</BOLD>#$1#g;
# print "$_";
#use the signal '?',you will come in noneGreedy mode
# $_ = "I'm much better \nthan Barney is\nat bowling,\nWilma.\n";
#m操作符,可以用来匹配字符串中的每一行，m 可以理解为multi lines.
# print "Found 'Wilma' at start of line\n " if /^wilma\b/im
#这里是用来说明多行匹配的
# open FILE,$filename
    # or die "Can't open '$filename':$!";
# my $lines = join '',<FILE>;
# $lines =~ s/^/$filename: /gm;
#下面这一小段程序用来批量对文件进行格式化的替换操作
# !/usr/bin/perl -w
# use strict;
# chomp(my $date = `date`);
# $^I = ".bak";
# while(<>){
	# s/^Author:.*/Author: Randal L. Schwartz/;
	# s/^Phone:.*\n//;
	# s/^Date:.*/Date:$date/;
	# print;
# }
#perl 自己有一个localtime函数，类似于系统的date命令，性能更好一些,以上的程序中，
	#我们修改后的内容如何又重新写回文件了呢。可以看见，在程序的开始，我们定义了
	#一个$^I变量，这个变量的操作符是undef，不会对程序造成任何影响。但是如果将其
	#赋值成为字符串，钻石操作符就会具有比平时更多的魔力。
#========================如下这一行程序有更大的魔力
#加入有个名字是Randall的名字应该被改正为Randal，只需要在命令行执行如下命令就够了
# perl -p -i.bak -w -e 's/Randall/Randal/g' fred*.dat  #这样岂不是很酷？
# -p 参数在执行的时候类似于写了一段while循环去读取文件并打印，如果选用-n，就不会
# 执行循环里面的print命令，-i.bak,相当于把要修改的文件设定为".bak"，-w开启警告过
#功能，-e则通知程序后面是可执行的代码，再后面则模糊匹配了一个类型文件集合
	#perl 引入了unless、until这样的控制结构
	#如下的几种写法就很高级了
# error("Invalid input") unless.&valid($input);
# $i *= 2 until $i > $j;
# print "", ($n+=2) while $n <10;
# &greet($_) foreach @person;
	#当然你可以按照你的理解去运用这些句子，perl已经准确的理解了你的意思
#perl 引入了裸块的概念，裸块就是独立执行的程序体，形式上用花括号括起来的.
# my @people = qw{ fred barney fred wilma dino barney fred pebbles };
# my %count;
# $count{$_}++ foreach @people;
#这种写法岂不是酷毙了、帅呆了.
# for ($_  = "bedrock";s/(.)//;) {
	# print "One character is:$1\n";
# }
# for(1..10){
   # print "I can count to $_\n";
# }
# while (<STDIN>) {
	# if (/__END__/) {
		# body...碰到这个记号说明再没有其他输入了
		# last;
	# }
	# elsif (/fred/) {
		# print;
	# }
	# else {
		# last;
	# }
# }
	# 下面例举一个分析文件中单词的程序
#while (<>) {
		# foreach(split) {
			# $total++;
			# next if /\W/;#为了讲解next控制符的，相当于continue控符
			# $valid++;
			# $count{$_}++;
		# }
	# }
# print "total things = $total,valid words = $valids\n";
# foreach my $word (sort keys %count) {
	# body...
	# print "$word was seen $count{$word} times.\n";
# }
# my @words = qw { fred barney pebbles dino wilma betty };
# my $errors = 0;
# foreach (@words) {
	#redo指令会走到这里##
	# print "Type the word '$_' :";
	# chomp(my $try = <STDIN>);
	# if($try ne $_){
		# print "Sorry - That's not right.\n\n";
		# $errors++;
		# redo;
	# }
# }
# print "You've completed the test,with $errors errors.\n";

# foreach (1..10) {
	# print "Iteration number $_.\n\n";
	# print "Please choose:last,next,redo,or none of the above?";
	# chomp(my $choice = <STDIN>);
	# print "\n";
	# last if $choice =~ /last/i;
	# next if $choice =~ /next/i;
	# redo if $choice =~ /redo/i;
	# print "That wasn't any of the choices...onward!\n\n";
# }

# print "That's all ,folks!\n";
#所以我们可以看见，last的作用是跳出循环，next是跳过当次循环，redo是将当前的循环
	#重新来一次
# LINE:while (<>) {
	# foreach  (split) {
		# last LINE if /__END__/;
		# print "jump out.\n";
	# }
# }
# use 5.010;
# my $last_name = $last_name{$someone} // '(No last name)';
# my $Verbose = $ENV{VERBOSE} // 1;
# print "I can talk to you!\n" if $Verbose;
	# use 5.010;
	# foreach my $try (0,undef,'0',1,25) {
		# print "Trying [$try] --->";
		# my $value = $try // 'default';
		# say "\tgot[$value]";
	# }
	#以上是为了测试//操作符的
	# use warnings;
	# my $name;
	# printf "%s",$name // '';
	#以下三种说法是等价的
	# ($m < $n ) && ($m = $n);
	# if ($m < $n) { $m = $n };
	# $m = $n if $m < $n;
	# 这些说法只存在表达上的不同，但是在控制结构的结果上是相同的
	# open my $fh '<', $filename
      # or die "Can't open '$filename':$|";
    # 以上两个语句只会选择性的执行一句话，利用了低优先级的短路or操作符只会执行一
	#一半的特性。
# my $mon = "Febrary";
# unless ($mon =~ /\AFeb/){
	# print "This month has at least thirty day.\n"
# } else {
	# print "Do you see what 's going on here?\n"
# }

# {
	# print "Please enter a number:";
	# chomp(my $n = <STDIN>);
	# my $root = sqrt $n;
	# print "The square root of $n is $root.\n";
# }
# for($_ = "bedrock";s/(.)//;){
	# print "One character is :$1.\n";
# }
# perl 中使用last和next来同义于c语言中的break和continue,redo 关键字用于使循环返
# 回到当前循环块的顶端，而不经过任何条件测试
# my @words = qw{ fred barney pebbles dino wilma betty };
# my $errors = 0;
# foreach (@words){
	# print "Type the word '$_':";
	# chomp(my $try = <STDIN>);
	# if($try ne $_){
		# print "Sorry - That's not right.\n\n";
		# $errors++;
		# redo;
	# }
# }
# print "You've completed the test,with $errors errors.\n";
# foreach(1..10){
	# print "Iteration number $_.\n\n";
	# print "Please choose:last,next,redo,or none of the above?";
	# chomp(my $choice = <STDIN>);
	# print "\n";
	# last if $choice =~ /last/i;
	# next if $choice =~ /next/i;
	# redo if $choice =~ /redo/i;
	# print "That wasn't any of the choices ... onward!\n\n";
# }
# print "That's all folks!\n";
# use 5.010;
# use warnings;
# my $name ;
# print "%s", $name || '';
