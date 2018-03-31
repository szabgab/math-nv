
# NV.pm will always load Math::MPFR iff it's available.
# Math::NV::no_mpfr will be set to 0 iff Math::MPFR loaded successfully.
# Otherwise $Math::NV::no_mpfr will be set to the error message that the
# attempt to load Math::MPFR produced.

# Smallest normal __float128 is:
# 3.3621031431120935062626778173217526e-4932

# Smallest normal (extended precision) long double is:
# 3.36210314311209350626e-4932

# Smallest normal double is:
# 2.2250738585072014e-308

use strict;
use warnings;
use Math::NV qw(:all);
use Config;

my $t = 8;

print "1..$t\n";

my $ok = 1;
my $exponent;

if($Math::NV::no_mpfr) {
  warn "\nMath::MPFR not available - skipping all other tests\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

if($Math::NV::mpfr_strtofr_bug == 1) {
  warn "Skipping tests - already run  in 08subnormal_mpfr.t\n";
  print "ok $_\n" for 1..$t;
  exit 0;
}

$Math::NV::mpfr_strtofr_bug = 1; # Force use of workaround routine.

warn "\nThese tests can take a few moments to complete\n";


my $check = Math::MPFR::Rmpfr_init2(300);

$exponent = $Config{nvtype} eq 'double' ? '-308' : '-4932';

for my $count(1 .. 50000, 200000 .. 340000) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e$exponent";

  Math::MPFR::Rmpfr_set_str($check, $str, 10, 0);

  my $nv = Math::MPFR::Rmpfr_get_NV($check, 0);

  if($nv != set_mpfr($str)) {
    warn "\n$nv != ", set_mpfr($str), "\n";
    $ok = 0;
    last;
  }

  my $out1 = scalar(reverse(unpack("h*", pack("F<", $nv))));

  my $out2;
  my $out = nv_mpfr($str);

  if(mant_dig() == 106) { # If NV is a double-double
    my @t = @$out;
    $out2 = $t[0] . $t[1];
  }
  else {$out2 = $out}

  unless($out1 eq $out2) {
    warn "For $str:\n $out1 ne $out2\n";
    if($] >= '5.022') {
      warn "The former is: ", sprintf("%a\n", $nv), sprintf("%.16e\n", $nv);
      warn "The latter is: ", sprintf "%a\n", unpack("F<", pack "h*", scalar reverse $out2);
    }
    $ok = 0;
    last;
  }

}

$Math::NV::no_warn = 2;

if($ok) {print "ok 1\n"}
else {print "not ok 1\n"}

$ok = 1;

for my $count(1 .. 50000, 200000 .. 340000) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e$exponent";

  my $str_copy = $str;
  my $perl_nv = $str_copy + 0;
  my $out;

  if(mant_dig() == 106) { # If NV is a double-double
    my $ret = nv_mpfr($str);
    my @t = @$ret;
    my $s = $t[0] . $t[1];
    $out = unpack("F<", pack "h*", scalar reverse $s);
  }
  else { $out = unpack("F<", pack "h*", scalar reverse nv_mpfr($str));}

  if($out == $perl_nv && !is_eq_mpfr($str)) {
    warn "For $str:\nperl and nv_mpfr() agree, but is_eq_mpfr($str) returns false\n";
    if($] >= '5.022') {
      warn "Perl says that $str evaluates to: ", sprintf "%a\n", $perl_nv;
      warn "nv_mpfr() says that $str evaluates to: ", sprintf "%a\n", $out;
    }
    $ok = 0;
    last;
  }

  if($out != $perl_nv  && is_eq_mpfr($str)) {
    warn "For $str:\nperl and nv_mpfr() disagree, but is_eq_mpfr($str) returns true\n";
    if($] >= '5.022') {
      warn "Perl says that $str evaluates to: ", sprintf "%a\n", $perl_nv;
      warn "nv_mpfr() says that $str evaluates to: ", sprintf "%a\n", $out;
    }
    $ok = 0;
    last;
  }

}

if($ok) {print "ok 2\n"}
else {print "not ok 2\n"}

$ok = 1;

for my $count(1 .. 50000, 150000 .. 222507) {

  my $str = sprintf "%06d", $count;
  substr($str, 1, 0, '.');
  $str .= "e-308";

  my $out1 = nv_mpfr($str, 53);
  my $out2 = nv_mpfr($str, 106);

  my @out = @$out2;

  if($out1 ne $out[0]) {
    warn "$out1 ne $out[0]\n";
    $ok = 0;
    last;
  }

  my $lsd = unpack("d<", pack "h*", scalar reverse $out[1]);

  unless($lsd == 0) {
    warn "\n$str: lsd ($out[1]) is not 0\n";
    $ok = 0;
    last;
  }
}

if($ok) {print "ok 3\n"}
else {print "not ok 3\n"}

$ok = 1;

eval{Math::MPFR::_dd_bytes('1e-2', 106)};

if(!$@) {
  for my $count(1 .. 50000, 200000 .. 340000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-308";

    my $out_a = nv_mpfr($str, 106);
    my $out_b = join '', Math::MPFR::_dd_bytes($str, 106);

    my @out1 = @$out_a;
    my @out2 = (substr($out_b, 0, 16), substr($out_b, 16, 16));

    if($out1[0] ne $out2[0]) {
      warn "msd: $out1[0] ne $out2[0]\n";
      $ok = 0;
      last;
    }

    if($out1[1] ne $out2[1]) {
      warn "lsd: $out1[1] ne $out2[1]\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 4\n"}
  else {print "not ok 4\n"}
}
else {
  warn "\n skipping test 4:\n\$\@:\n$@\n";
  print "ok 4\n";
}

$ok = 1;

my $save_prec = Math::MPFR::Rmpfr_get_default_prec();

if(mant_dig() == 113) {
  Math::MPFR::Rmpfr_set_default_prec(113);
  my @str1 = ('0.1e-16494', '0.111111e-16494',
              '0.1e-16493', '0.101e-16493', '0.11e-16493',
              '0.11e-16492','0.1101e-16492', '0.111e-16492',
              '0.101e-16491', '0.10101e-16491', '0.1011e-16491', '0.11101e-16491', '0.1101e-16491', '0.1111e-16491',);

  my @str2 = ('0', '0',
              '0.1e-16493', '0.1e-16493', '0.1e-16492',
              '0.11e-16492', '0.11e-16492', '0.10e-16491',
              '0.101e-16491','0.101e-16491', '0.110e-16491', '0.111e-16491', '0.11e-16491', '0.1e-16490');

  my $len = scalar(@str1);
  die "size mismatch" if @str1 != @str2;

  for(my $i = 0; $i < $len; $i++) {
    if(set_mpfr('0b' . $str1[$i]) != set_mpfr('0b' . $str2[$i])) {
      warn "\n", Math::NV::get_relevant_prec(Math::MPFR->new($str1[$i], 2)), ": $str1[$i] != $str2[$i]\n";
      $ok = 0;
    }
  }
}
elsif(mant_dig() == 64) {
  Math::MPFR::Rmpfr_set_default_prec(64);
  my @str1 = ('0.1e-16445', '0.111111e-16445',
              '0.1e-16444', '0.101e-16444', '0.11e-16444',
              '0.11e-16443','0.1101e-16443', '0.111e-16443',
              '0.101e-16442', '0.10101e-16442', '0.1011e-16442', '0.11101e-16442', '0.1101e-16442', '0.1111e-16442',);

  my @str2 = ('0', '0',
              '0.1e-16444', '0.1e-16444', '0.1e-16443',
              '0.11e-16443', '0.11e-16443', '0.10e-16442',
              '0.101e-16442','0.101e-16442', '0.110e-16442', '0.111e-16442', '0.11e-16442', '0.1e-16441');

  my $len = scalar(@str1);
  die "size mismatch" if @str1 != @str2;

  for(my $i = 0; $i < $len; $i++) {
    if(set_mpfr('0b' . $str1[$i]) != set_mpfr('0b' . $str2[$i])) {
      warn "\n", Math::NV::get_relevant_prec(Math::MPFR->new($str1[$i], 2)), ": $str1[$i] != $str2[$i]\n";
      $ok = 0;
    }
  }
}
else {
  Math::MPFR::Rmpfr_set_default_prec(53);
  my @str1 = ('0.1e-1074', '0.111111e-1074',
              '0.1e-1073', '0.101e-1073', '0.11e-1073',
              '0.11e-1072','0.1101e-1072', '0.111e-1072',
              '0.101e-1071', '0.10101e-1071', '0.1011e-1071', '0.11101e-1071', '0.1101e-1071', '0.1111e-1071',);

  my @str2 = ('0', '0',
              '0.1e-1073', '0.1e-1073', '0.1e-1072',
              '0.11e-1072', '0.11e-1072', '0.10e-1071',
              '0.101e-1071','0.101e-1071', '0.110e-1071', '0.111e-1071', '0.11e-1071', '0.1e-1070');

  my $len = scalar(@str1);
  die "size mismatch" if @str1 != @str2;

  for(my $i = 0; $i < $len; $i++) {
    if(set_mpfr('0b' . $str1[$i]) != set_mpfr('0b' . $str2[$i])) {
      warn "\n", Math::NV::get_relevant_prec(Math::MPFR->new($str1[$i], 2)), ": $str1[$i] != $str2[$i]\n";
      $ok = 0;
    }
  }
}

Math::MPFR::Rmpfr_set_default_prec($save_prec);

if($ok) { print "ok 5\n" }
else {print "not ok 5\n" }

if($Math::MPFR::VERSION < 4.02) {
  warn "\nSkipping remaining tests.\nThey require Math-MPFR-4.02 and $Math::MPFR::VERSION is installed\n";
  print "ok $_\n" for 6..$t;
  exit 0;
}

$ok = 1;

$Math::NV::no_warn = 0;

eval{Math::MPFR::_d_bytes('1e-2', 53)};

if(!$@) {
  for my $count(1 .. 50000, 200000 .. 340000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-308";

    my $out1 = nv_mpfr($str, 53);
    my $out2 = join '', Math::MPFR::_d_bytes($str, 53);

    if($out1 ne $out2) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 6\n"}
  else {print "not ok 6\n"}
}
else {
  warn "\n skipping test 6:\n\$\@:\n$@\n";
  print "ok 6\n";
}



$ok = 1;

eval{Math::MPFR::_ld_bytes('1e-2', Math::MPFR::LDBL_MANT_DIG)};

if(!$@) {
  for my $count(1 .. 50000, 200000 .. 340000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-4932";

    my $out1 = nv_mpfr($str, Math::MPFR::LDBL_MANT_DIG);
    my $out2 = join '', Math::MPFR::_ld_bytes($str, Math::MPFR::LDBL_MANT_DIG);

    if($out1 ne $out2 && $out1 ne ('0000'. $out2) && $out1 ne ('000000000000'. $out2)) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 7\n"}
  else {print "not ok 7\n"}
}
else {
  warn "\n skipping test 7:\n\$\@:\n$@\n";
  print "ok 7\n";
}

$ok = 1;

eval{Math::MPFR::_f128_bytes('1e-2', 113)};

if(!$@) {
  for my $count(1 .. 50000, 200000 .. 340000) {

    my $str = sprintf "%06d", $count;
    substr($str, 1, 0, '.');
    $str .= "e-4932";

    my $out1 = nv_mpfr($str, 113);
    my $out2 = join '', Math::MPFR::_f128_bytes($str, 113);

    if($out1 ne $out2) {
      warn "$out1 ne $out2\n";
      $ok = 0;
      last;
    }
  }

  if($ok) {print "ok 8\n"}
  else {print "not ok 8\n"}
}
else {
  warn "\n skipping test 8:\n\$\@:\n$@\n";
  print "ok 8\n";
}

$ok = 1;


