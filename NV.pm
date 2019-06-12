## This file generated by InlineX::C2XS (version 0.22) using Inline::C (version 0.53)
package Math::NV;
use warnings;
use strict;
use Math::MPFR qw(:mpfr);
use 5.010;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

$Math::NV::VERSION = '2.02';

DynaLoader::bootstrap Math::NV $Math::NV::VERSION;

@Math::NV::EXPORT = ();
@Math::NV::EXPORT_OK = qw(
    nv nv_type mant_dig ld2binary ld_str2binary is_eq
    bin2val Cprintf Csprintf nv_mpfr is_eq_mpfr
    set_C set_mpfr is_inexact
    );

%Math::NV::EXPORT_TAGS = (all => [qw(
    nv nv_type mant_dig ld2binary ld_str2binary is_eq
    bin2val Cprintf Csprintf nv_mpfr is_eq_mpfr
    set_C set_mpfr is_inexact
    )]);

if($Math::MPFR::VERSION < 4.07) {
   die " Math-MPFR version needs to be 4.07 or later\n This is only Math-MPFR-$Math::MPFR::VERSION\n";
}

## max NV finite values ##
# double    : 1.7976931348623157e+308
#long double: 1.18973149535723176502e4932
# __float128: 1.18973149535723176508575932662800702e4932

## normal min values ##
# double     : (2 ** - 1022) : 0.1E-1021  : 2.2250738585072014e-308
# long double: (2 ** -16382) : 0.1E-16381 : 3.36210314311209350626e-4932
# __float128 : (2 ** -16382) : 0.1E-16381 : 3.36210314311209350626267781732175260e-4932

  $Math::NV::DBL_MIN    = Math::MPFR->new(2 **  -1022);
  $Math::NV::LDBL_MIN   = Math::MPFR->new(2 ** -16382);
  $Math::NV::FLT128_MIN = $Math::NV::LDBL_MIN;

## denorm_min values ##
# double     : (2 **  -1074) : 0.1E-1073  : 4.9406564584124654e-324
# long double: (2 ** -16445) : 0.1E-16444 : 3.64519953188247460253e-4951
# __float128 : (2 ** -16494) : 0.1E-16493 : 6.47517511943802511092443895822764655e-4966

  $Math::NV::DBL_DENORM_MIN = Math::MPFR->new(2);
  Rmpfr_div_2ui($Math::NV::DBL_DENORM_MIN, $Math::NV::DBL_DENORM_MIN, 1075, 0);        # (2 ** -1074)
  $Math::NV::LDBL_DENORM_MIN = Math::MPFR->new(2);
  Rmpfr_div_2ui($Math::NV::LDBL_DENORM_MIN, $Math::NV::LDBL_DENORM_MIN, 16446, 0);     # (2 ** -16445)
  $Math::NV::FLT128_DENORM_MIN = Math::MPFR->new(2);
  Rmpfr_div_2ui($Math::NV::FLT128_DENORM_MIN, $Math::NV::FLT128_DENORM_MIN, 16495, 0); # (2 ** -16494)

  $Math::NV::DBL_DENORM_MIN_MIN    = Math::MPFR->new();
  $Math::NV::LDBL_DENORM_MIN_MIN   = Math::MPFR->new();
  $Math::NV::FLT128_DENORM_MIN_MIN = Math::MPFR->new();

  # For all x, DENORM_MIN_MIN < x < DENORM_MIN, x should round to DENORM_MIN when subnormalized.
  # For all x, x <= DENORM_MIN_MIN, x is subnormalized to 0.

  Rmpfr_div_2ui($Math::NV::DBL_DENORM_MIN_MIN,    $Math::NV::DBL_DENORM_MIN,    1, MPFR_RNDN); # (2 ** -1075)
  Rmpfr_div_2ui($Math::NV::LDBL_DENORM_MIN_MIN,   $Math::NV::LDBL_DENORM_MIN,   1, MPFR_RNDN); # (2 ** -16446)
  Rmpfr_div_2ui($Math::NV::FLT128_DENORM_MIN_MIN, $Math::NV::FLT128_DENORM_MIN, 1, MPFR_RNDN); # (2 ** -16495)

  %Math::NV::DENORM_MIN = ('0'   => Math::MPFR->new(0),
                           '53'  => $Math::NV::DBL_DENORM_MIN,
                           '64'  => $Math::NV::LDBL_DENORM_MIN,
                           '106' => $Math::NV::DBL_DENORM_MIN,
                           '113' => $Math::NV::FLT128_DENORM_MIN,
                           '53MIN'  => $Math::NV::DBL_DENORM_MIN_MIN,
                           '64MIN'  => $Math::NV::LDBL_DENORM_MIN_MIN,
                           '106MIN' => $Math::NV::DBL_DENORM_MIN_MIN,
                           '113MIN' => $Math::NV::FLT128_DENORM_MIN_MIN,
                           );

if(Math::MPFR::_ld_subnormal_bug()) {
  $Math::NV::_ld_subnormal_bug = 1;
}
else {
  $Math::NV::_ld_subnormal_bug = 0;
}

# With mpfr-3.1.5 and earlier, the ternary value returned
# by mpfr_strtofr is unreliable - thereby making that function
# unusable with mpfr_subnormalize.
$Math::NV::mpfr_strtofr_bug = MPFR_VERSION() <= 196869 ? 1 : 0;

$Math::NV::no_warn = 0; # set to 1 to disable warning about non-string argument
                        # set to 2 to disable output of the 2 non-matching values
                        # set to 3 to disable both of the above

# %_itsa is utilised in the formulation of the diagnostic message
# when it's detected that the provided arg is not a string.

my %_itsa = (
  1 => 'UV',
  2 => 'IV',
  3 => 'NV',
  4 => 'string',
  0 => 'unknown',
);

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub ld2binary {
  my @ret = _ld2binary($_[0]);
  my $prec = pop(@ret);
  my $exp = pop(@ret);
  my $mantissa = join '', @ret;
  return ($mantissa, $exp, $prec);
}

sub ld_str2binary {
  my @ret = _ld_str2binary($_[0]);
  my $prec = pop(@ret);
  my $exp = pop(@ret);
  my $mantissa = join '', @ret;
  return ($mantissa, $exp, $prec);
}

sub bin2val {
  my($mantissa, $exp, $prec) = (shift, shift, shift);
  my $sign = $mantissa =~ /^\-/ ? '-' : '';
  # Remove everything upto and including the radix point
  # as it now contains no useful information.
  $mantissa =~ s/.+\.//;
  # For our purposes the values $prec and $exp need
  # to be reduced by 1.
  $exp--;

  # Perl bugs make the following (commented out) code unreliable,
  # so we now hand the calculations over to C.
  # (And there's no need to decrement $prec.)
  #$prec--;
  #for(0..$prec) {
  #  if(substr($mantissa, $_, 1)) {$val += 2**$exp}
  #  $exp--;
  #}
  my @mantissa = split //, $mantissa;
  my $val = _bin2val($prec, $exp, \@mantissa);
  $sign eq '-' ? return -$val : return $val;
}

sub is_eq {
  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa); # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_eq() is $_itsa{$itsa}, not a string - probably not what you want"
    if $itsa != 4;
  }
  my $nv = $_[0];
  my $check = nv($_[0]);
  return 1 if $nv == $check;
  unless($Math::NV::no_warn & 2) {
    if(mant_dig() == 64) {
      # pack/unpack like to deliver irrelevant (ie ignored) leading bytes
      # if NV is 80-bit long double
      my $first = scalar(reverse(unpack("h*", pack("F<", $nv))));
      $first = substr($first, length($first) - 20, 20);
      my $second = scalar(reverse(unpack("h*", pack("F<", $check))));
      $second = substr($second, length($second) - 20, 20);
      warn "\nIn is_eq:\nperl: $first vs C: $second\n";
      if($] > 5.02) {
        warn "perl: ", sprintf("%a", $nv), " vs mpfr: ", sprintf("%a", $check), "\n";
      }
    }
    else {
      warn "\nIn is_eq:\nperl: ",
        scalar(reverse(unpack("h*", pack("F<", $nv)))), " vs C: ",
        scalar(reverse(unpack("h*", pack("F<", $check)))), "\n";
      if($] > 5.02) {
        warn "perl: ", sprintf("%a", $nv), " vs mpfr: ", sprintf("%a", $check), "\n";
      }
    }
  }
  return 0;
}

sub is_eq_mpfr {

  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa); # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_eq() is $_itsa{$itsa}, not a string - probably not what you want"
    if $itsa != 4;
  }

  my $fr;
  my $nv = $_[0];
  my $bits = mant_dig();
  $bits = 2098 if $bits == 106;

  if($bits == 2098) {
    $fr = Rmpfr_init2($bits);
    Rmpfr_strtofr($fr, $nv, 0, 0);
  }
    else { # OPEN ELSE 1

    $fr = Rmpfr_init2($bits);
    my $inex = Rmpfr_strtofr($fr, $nv, 0, 0);

    unless($Math::NV::mpfr_strtofr_bug) {
      $fr = _subnormalize($_[0], $bits);
    }
    else {
      $fr = Rmpfr_init2($bits);
      Rmpfr_strtofr($fr, $nv, 0, 0);
      my $fr_bits = get_relevant_prec($fr); # check for subnormality

      Rmpfr_set($fr, get_subnormal($_[0], $fr_bits, $bits, $fr), 0);
    }
  } # CLOSE ELSE1

  if($nv == Rmpfr_get_NV($fr, 0)) {return 1}

  # Values don't match

  unless($Math::NV::no_warn & 2) {
    if($bits == 64) {
      # pack/unpack like to deliver irrelevant (ie ignored) leading bytes
      # if NV is 80-bit long double
      my $first = scalar(reverse(unpack("h*", pack("F<", $nv))));
      $first = substr($first, length($first) - 20, 20);
      my $second = scalar(reverse(unpack("h*", pack("F<", Rmpfr_get_NV($fr, 0)))));
      $second = substr($second, length($second) - 20, 20);
      warn "\nIn is_eq_mpfr: $_[0]\nperl: $first vs mpfr: $second\n";
      if($] > 5.02) {
        warn "perl: ", sprintf("%a", $nv), " vs mpfr: ", sprintf("%a", Rmpfr_get_NV($fr, 0)), "\n";
      }
    }
    else {
      warn "\nIn is_eq_mpfr: $_[0]\nperl: ",
        scalar(reverse(unpack("h*", pack("F<", $nv)))), " vs mpfr: ",
        scalar(reverse(unpack("h*", pack("F<", Rmpfr_get_NV($fr, 0))))), "\n";
      if($] > 5.02) {
        warn "perl: ", sprintf("%a", $nv), " vs mpfr: ", sprintf("%a", Rmpfr_get_NV($fr, 0)), "\n";
      }
    }
  }
  return 0;

}

sub nv_mpfr {

  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa);  # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_eq() is $_itsa{$itsa}, not a string - probably not what you want"
    if $itsa != 4;
  }

  my($val, $bits);

  $bits = defined($_[1]) ? $_[1] : mant_dig();

  return _double_double($_[0]) if $bits == 106; # doubledouble

  if($bits == mant_dig() ) { # 53, 64 or 113 bits

    unless($Math::NV::mpfr_strtofr_bug) {
      $val = _subnormalize($_[0], $bits);
    }
    else { # ELSE1
      $val = Rmpfr_init2($bits);
      Rmpfr_strtofr($val, $_[0], 0, 0);
      my $val_bits = get_relevant_prec($val); # check for subnormality.

      Rmpfr_set($val, get_subnormal($_[0], $val_bits, $bits, $val), MPFR_RNDN);

    } # ELSE1

    my $nv = Rmpfr_get_NV($val, 0);
    my $ret = scalar(reverse(unpack("h*", pack("F<", $nv))));

    return $ret;
  }

  if($bits == 53) {

    unless($Math::NV::mpfr_strtofr_bug) {
      $val = _subnormalize($_[0], 53);
    }
    else { # ELSE1
      $val = Rmpfr_init2($bits);
      Rmpfr_strtofr($val, $_[0], 0, 0);
      my $val_bits = get_relevant_prec($val); # check for subnormality.

      Rmpfr_set($val, get_subnormal($_[0], $val_bits, $bits, $val), MPFR_RNDN);

    } # ELSE1

    my $nv = Rmpfr_get_d($val, 0);
    return scalar(reverse(unpack("h*", pack("d<", $nv))));
  }

  if($bits == 64) {
    my @bytes = Math::MPFR::_ld_bytes($_[0], 64);
    return join('', @bytes);
  }

  if($bits == 113) {

    my $t;
    eval{$t = Math::MPFR::_have_IEEE_754_long_double();}; # needs Math-MPFR-3.33, perl-5.22.
    if(!$@ && $t) {
      my @bytes = Math::MPFR::_ld_bytes($_[0], 113);
      return join('', @bytes);
    }
    else { # assume __float128 (though that might not be the case)
        my @bytes = Math::MPFR::_f128_bytes($_[0], 113);
      return join('', @bytes);
    }
  }

  die "Unrecognized value for bits ($bits)";
}

sub set_mpfr {

  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa);  # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_eq() is $_itsa{$itsa}, not a string - probably not what you want"
    if $itsa != 4;
  }

  my $bits = mant_dig();
  $bits = 2098 if $bits == 106;

  my $val;

  # my $val = Rmpfr_init2($bits);
  # my $inex = Rmpfr_strtofr($val, $_[0], 0, 0);

  if($bits == 2098) {
    $val = Rmpfr_init2(2098);
    Rmpfr_strtofr($val, $_[0], 0, 0);
    return Rmpfr_get_ld($val, 0);
  }

  die "In set_mpfr: unrecognized nv precision of $bits bits"
    unless($bits == 53 || $bits == 64 || $bits == 113);

    unless($Math::NV::mpfr_strtofr_bug) {
      $val = _subnormalize($_[0], $bits);
    }
    else { # ELSE1
      $val = Rmpfr_init2($bits);
      Rmpfr_strtofr($val, $_[0], 0, 0);
      my $val_bits = get_relevant_prec($val); # check for subnormality.

      Rmpfr_set($val, get_subnormal($_[0], $val_bits, $bits, $val), MPFR_RNDN);

    } # ELSE1

  return Rmpfr_get_NV($val, MPFR_RNDN);

}

sub is_inexact {

  die "is_inexact() requires at least mpfr-3.1.6"
    if $Math::NV::mpfr_strtofr_bug;

  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa);  # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_inexact() is $_itsa{$itsa}, not a string - possibly not what you want"
    if $itsa != 4;
  }

  my $bits = mant_dig();
  $bits = 2098 if $bits == 106;

  my $val = Rmpfr_init2($bits);

  my $inex = Rmpfr_strtofr($val, $_[0], 0, 0);
  my $nv = atonv($_[0]);

  my $cmp = Rmpfr_cmp_NV($val, $nv) * -1;

  return $inex if !$cmp;
  return $cmp;
}

sub set_C {
  unless($Math::NV::no_warn & 1) {
    my $itsa = $_[0];
    $itsa = _itsa($itsa);  # make sure that $_[0] has POK flag set && all numeric flags unset
    warn "Argument given to is_eq() is $_itsa{$itsa}, not a string - probably not what you want"
    if $itsa != 4;
  }
  return _set_C($_[0]);
}


sub _double_double {
  my $val = Rmpfr_init2(2098);
  Rmpfr_set_str($val, shift, 0, 0);
  my @val = _dd_obj($val);
  return [scalar(reverse(unpack("h*", pack("d<", $val[0])))),
          scalar(reverse(unpack("h*", pack("d<", $val[1]))))];
}

sub _dd_obj {
  my $obj = shift;
  my $msd = Rmpfr_get_d($obj, 0);
  if($msd == 0 || $msd != $msd || $msd / $msd != 1) {return ($msd, 0.0)} # it's  inf, nan or zero.
  $obj -= $msd;
  return ($msd, Rmpfr_get_d($obj, 0));
}

# use _subnormalize instead if MPFR_VERSION > 196869
sub get_subnormal {

  my($str, $prec, $bits) = (shift, shift, shift);

  my $signbit = Rmpfr_signbit($_[0]) ? -1 : 1;

  # If $prec < 0, set $val to (appropriately signed) 0.
  if($prec < 0) {
    return $Math::NV::DENORM_MIN{'0'} * $signbit;
  }

  # If prec == 0, then the value is less than the
  # minimum subnormal number.
  if($prec == 0) {
    return $Math::NV::DENORM_MIN{$bits} * $signbit if abs($_[0]) > $Math::NV::DENORM_MIN{"${bits}MIN"};
    return $Math::NV::DENORM_MIN{'0'} * $signbit;
  }

  # Can't set precision to 1 bit with
  # older versions of the mpfr library
  if($prec == 1) {
    return ($Math::NV::DENORM_MIN{$bits} * $signbit * 2) if(abs($_[0]) >= $Math::NV::DENORM_MIN{"${bits}MIN"}
                                                                          + $Math::NV::DENORM_MIN{$bits});
    return $Math::NV::DENORM_MIN{$bits} * $signbit;
  }

  my $val = Rmpfr_init2($prec);
  Rmpfr_set_str($val, $str, 0, 0);
  return $val;
}

sub get_relevant_prec {
  my $bits = Rmpfr_get_prec($_[0]);
  die "Unrecognized precision ($bits) handed to get_relevant_prec()"
    unless ($bits == 53 || $bits == 64 || $bits == 113 || $bits == 106 || $bits == 2098);

  my $init = $bits == 53 || $bits == 106 || $bits == 2098 ? 1074
                                                           : $bits == 64 ? 16445
                                                                         : 16494;

  return $init + Rmpfr_get_exp($_[0]);

}

# use get_subnormal instead if MPFR_VERSION <= 196869
sub _subnormalize {
  # Called as: $val = _subnormalize($string, $bits);
  # mpfr_subnormalize(fr, inex, MPFR_RNDN);

  my $emin = Rmpfr_get_emin();
  my $emax = Rmpfr_get_emax();

# Default precision shouldn't matter as we're
# specifying precision of $val correctly.
# my $original_prec = Rmpfr_get_default_prec();

  my $sub_emin = $_[1] == 53 ? -1073
                             : $_[1] == 64 ? -16444
                                                : -16493; # $_[1] == 113

  my $sub_emax = $_[1] == 53 ? 1024
                             : 16384;

#  Rmpfr_set_default_prec($_[1]);

  Rmpfr_set_emin($sub_emin);
  Rmpfr_set_emax($sub_emax);

  my $val = Rmpfr_init2($_[1]);
  my $inex = Rmpfr_strtofr($val, $_[0], 0, 0);

  Rmpfr_subnormalize($val, $inex, 0);

  Rmpfr_set_emin($emin);
  Rmpfr_set_emax($emax);
# Rmpfr_set_default_prec($original_prec);

  return $val;
}

1;

__END__

