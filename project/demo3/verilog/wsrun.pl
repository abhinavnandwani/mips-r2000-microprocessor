#!/s/std/bin/perl

use strict;

my $open_wave_viewer = 0;

my $first_arg;
my $do_file='';
my $prog_file='';
my $addr_file='';
my $file_list='';
my @prog_list;
my $step_count = 1;
my $brief = 0;
my $max_failures = 200;
my $n_cycles = 10000;
my $pipeline_mode = 0;
my $args='';

my $tb_top_module;
my @v_files;
my $n_failures = 0;
my $trace_ext = ".trace";
my $aligned = 0;
my $seed=0;
my $compileonly = 0;

my $bin_root="/u/s/i/sinclair/public/html/courses/cs552/spring2022/handouts/bins";

if ($#ARGV < 1) {
  print_usage();
  exit 0;
}

while (1) {
  $first_arg = $ARGV[0];
  if ($first_arg =~ /^-/) {
    if ($first_arg =~ /^-compileonly/) {
      $compileonly = 1;
    }
    if ($first_arg =~ /^-align/) {
      $aligned = 1;
    }
    if ($first_arg =~ /^-pipe/) {
      $pipeline_mode = 1;
      $trace_ext = ".ptrace";
    }
    if ($first_arg =~ /^-help/) {
      print_usage();
      exit 0;
    }
    if ($first_arg =~ /^-seed/) {
      shift @ARGV;
      $seed = $ARGV[0];
    }
    if ($first_arg =~ /^-args/) {
      shift @ARGV;
      $args = $ARGV[0];
    }
    if ($first_arg =~ /^-n/) {
      shift @ARGV;
      $n_cycles = $ARGV[0];
    }
    if ($first_arg =~ /^-brief/) {
      $brief = 1;
    }
    if ($first_arg =~ /^-maxf/) {
      shift @ARGV;
      $max_failures = $ARGV[0];
    }
    if ($first_arg =~ /^-wave/) {
      $open_wave_viewer = 1;
    }
    if ($first_arg =~ /^-do/) {
      shift @ARGV;      
      $do_file = $ARGV[0];
    }
    if ($first_arg =~ /^-prog/) {
      shift @ARGV;      
#      $prog_file = $ARGV[0];
      push @prog_list, $ARGV[0];
    }
    if ($first_arg =~ /^-addr/) {
      shift @ARGV;      
      $addr_file = $ARGV[0];
      $addr_file =~ s/\//\/\//g;
    }
    if ($first_arg =~ /^-list/) {
      shift @ARGV;
      $file_list = $ARGV[0];
      if ( !(-r $file_list) ) {
        die "Cannot find file list $file_list";
      }
      open(F1, "$file_list");
      @prog_list = <F1>;
      chomp @prog_list;
      close F1;
    }
    shift @ARGV;
  } else {
    last;
  }
}

if ($#prog_list >= 0) {
  if ( bin_exists("$bin_root/wiscalculator") != 0 ) {
    print "Cannot find wiscalculator in your path. Add /u/s/i/sinclair/public/html/courses/cs552/spring2022/handouts/bins to your path\n";
    exit -1;
  }
}

my $iter_count = 0;
my %simulation_results;

if ($#prog_list >= 0) {
  foreach my $a (@prog_list) {
    $prog_file = $a;
    next if (length($prog_file) <= 1);
    print "Program $iter_count $prog_file\n";
    $simulation_results{$prog_file} = "FAILED";
    compile_assemble();
    if ($iter_count == 0) {
      compile_verilog();
    }
    run_verilog();
    run_arch_sim();
    $iter_count++;
    $step_count = 1;
    if ($n_failures > $max_failures) {
      print "Too many failures...stopping early\n";
      last;
    }
  }
  print_separator(0);
  print "Final log, saved in summary.log\n";
  open(F1, ">summary.log");
  foreach my $a (sort keys %simulation_results) {
    my $v = $simulation_results{$a};
    print "$a $v\n";
    print F1 "$a $v\n";
  }
  close F1;
} else {
  compile_verilog();
  if ($compileonly == 0) {
      run_verilog();
  }
}

if ($open_wave_viewer) {
  system("vsim -view dataset=dump.wlf");
}


sub compile_verilog() {

  $tb_top_module = shift @ARGV;

  foreach my $a (@ARGV) {
    if ($a =~ /\.syn\.v/) {
      print "Skipping $a, seems like a file meant for synthesis\n";
    } else {
      push @v_files, $a;
    }
  }

  print_separator(1);

  if (!$brief) {
    print "Compiling the following verilog files: ";
    foreach my $a (@v_files) {
      print "$a ";
    }
    print "\n";
    print "Top module: $tb_top_module\n";
    print "Compilation log in wsrun.log\n";
  }


  my @cmds;
  
  push @cmds, "rm -rf __work dump.wlf dump.vcd diff.trace diff.ptrace archsim.trace archsim.ptrace verilogsim.trace verilogsim.ptrace";
  push @cmds, "vlib __work";
  push @cmds, "vlog +define+RANDSEED=3 -work __work @v_files";

  system("rm wsrun.log");
  foreach my $a (@cmds) {
    if ($brief) {
      $a = "$a >> wsrun.log";
    }
    print "Executing $a\n";
    system($a);
  }

}

sub run_verilog() {
  print_separator(1);
  print "Running Verilog simulation...details in wsrun.log\n";
  my @cmds;
  my $seed_string;
  if ($seed == 0) {
    $seed_string = " ";
  } else {
    $seed_string = "+seed=$seed ";
  }
  if (length($addr_file) >= 1) {
    $args .= " +addr_trace_file_name=$addr_file ";
  }
  if (length($do_file) >= 1) {
    push @cmds, "echo \"run -all\" | vsim $seed_string $args -c $tb_top_module -lib __work -do $do_file ";
    push @cmds, "vcd2wlf dump.vcd dump.wlf";
  } else {
    # 2022 version
    push @cmds, "vsim $seed_string $args -c $tb_top_module -lib __work -voptargs=+acc -wlf dump.wlf  -do \"log -howmany -rec /* ; run -all\" ";
    # push @cmds, "vcd2wlf dump.vcd dump.wlf";
    # 2020 version
    #push @cmds, "echo \"run -all\" | vsim $seed_string $args -c $tb_top_module -lib __work ";
    #push @cmds, "vcd2wlf dump.vcd dump.wlf";
  }
  foreach my $a (@cmds) {
    if ($brief) {
      $a = "$a >> wsrun.log";
    }
    system($a);
  }


  if (-r "dump.wlf") {
    print_separator(1);
    print "Verilog simulation successful\n";
    if ($#prog_list >= 0) {
      print "See verilogsim.log and verilogsim$trace_ext for output\n";
    }
    print "Created a dump file dump.wlf.\nTo view waveforms, open with\nvsim -view dataset=dump.wlf\n";
  } else {
    print "Did not create a dump file...something went wrong.  Did you remember to include \$dumpfile(\"dump.vcd\") in your testbench?\n";
    exit(-1);
  }
}

sub compile_assemble() {
  print_separator(1);
  
  print "Compiling $prog_file\n";
  my $retval = bin_exists("$bin_root/assemble-long.sh");
  if ( ($retval == 0) && (-r $prog_file) ) {
    my $c0 = "$bin_root/assemble-long.sh $prog_file";
    if ($brief) {
      $c0 = "$c0 >> wsrun.log";
    }
    system($c0);
  } elsif (! -r $prog_file) {
    print "Did not find program to compile ($prog_file), retval = $retval\n";
    die "";
  } else {
    print "Could not find the assembler assemble.sh in your PATH\n";
    die "";
  }
}

sub bin_exists() {
  return 0;
  my ($name) = @_;
  my $retval;
  system("which $name > /dev/null"); $retval = ($? >> 8);
  return $retval;
}

sub run_arch_sim() {
  my $relax_diff = 1;
  if (length($prog_file) < 1) {
    return;
  }
  print_separator(1);
  print "Running arch simulator wiscalculator...\n";
  my $retval;
  my $c0;
  if ($aligned) {
    $c0 = "$bin_root/wiscalculator -align loadfile_all.img > archsim.out";
  } else {
    $c0 = "$bin_root/wiscalculator loadfile_all.img > archsim.out";
  }
  system($c0);
  if (!( -r "archsim.trace" ) ) {
    die "Running wiscalcualtor did not create trace...something wrong. Contact cs552 staff\n";
  }
  if (!( -r "verilogsim$trace_ext" ) ) {
    die "Did not find verilog simulation trace (verilogsim$trace_ext)...something wrong. Contact cs552 staff\n";
  }
  print_separator(1);
  print "Comparing arch simulation trace against verilog simulation trace\n";
  if (!$pipeline_mode) {
    $c0 = "$bin_root/wsdiff.pl $prog_file archsim.trace verilogsim.trace > diff.trace";
    system($c0);
    $c0 = "diff archsim.trace verilogsim.trace";
    system($c0); $retval = ($? >> 8);
  } else {
    $c0 = "$bin_root/wsdiff2.pl $prog_file archsim.trace archsim.ptrace verilogsim.ptrace > diff.ptrace";
    system($c0); 
    $c0 = "$bin_root/wsdiff2.pl -relax $prog_file archsim.trace archsim.ptrace verilogsim.ptrace > /dev/null";
    system($c0); $relax_diff = ($? >> 8);
    $c0 = "diff archsim.ptrace verilogsim.ptrace";
    system($c0); $retval = ($? >> 8);
  }
  if ($retval != 0) {
    print "FAILED. See differences in diff$trace_ext. Search for ***DIFF***\n";
    if ($relax_diff == 0) {
      print "RELAX-PASS: Relaxed diff passed. Most likely multiple writes to memory,\nregister file, or multiple reads from memory\n";
      $simulation_results{$prog_file} = "RELAX-PASS";
    }
    print "Use diff -yw --color (or vimdiff) archsim$trace_ext verilogsim$trace_ext to see differences side by side.\n";
    print "Open dump.wlf in modelsim using, vsim -view dataset=dump.wlf\n";
    print "Program source listing and raw bits are in loadfile.list. Open using gedit loadfile.lst\n";

    $n_failures++;
  } else {
    my $cmd="grep sim_cycles verilogsim.log  | awk '{print \$3}'";
    my $nsim_cycles = `$cmd`; 
    $cmd="grep inst_count verilogsim.log  | awk '{print \$3}'";
    my $nsim_icount = `$cmd`; 
    $cmd="grep dcachehit_count verilogsim.log  | awk '{print \$3}'";
    my $dcachehit_icount = `$cmd`; 
    $cmd="grep icachehit_count verilogsim.log  | awk '{print \$3}'";
    my $icachehit_icount = `$cmd`; 
    $cmd="grep dcachereq_count verilogsim.log  | awk '{print \$3}'";
    my $dcachereq_count = `$cmd`; 
    $cmd="grep icachereq_count verilogsim.log  | awk '{print \$3}'";
    my $icachereq_count = `$cmd`; 

    chomp($nsim_cycles);
    chomp($nsim_icount);
    my $cpi = sprintf("%3.1f", $nsim_cycles/($nsim_icount+0.01) );
    my $ihit_rate;
    my $dhit_rate;
    if ($dcachereq_count == 0) {
      $dhit_rate = 0;
    } else {
      $dhit_rate = sprintf("%3.1f", 100*$dcachehit_icount/($dcachereq_count) );
    }
    if ($icachereq_count == 0) {
      $ihit_rate = 0;
    } else {
      $ihit_rate = sprintf("%3.1f", 100*$icachehit_icount/($icachereq_count) );
    }
    print "SUCCESS. Simulations match for $prog_file.\n";
    $simulation_results{$prog_file} = "SUCCESS CPI:$cpi CYCLES:$nsim_cycles ICOUNT:$nsim_icount IHITRATE: $ihit_rate DHITRATE: $dhit_rate";
  }
}

sub print_separator() {
  my ($inc_step_count) = @_;
  my $separator="-------------------------------------------------";
  print "$separator\n";
  if ($inc_step_count) {
    print "Step: $step_count\n";
    $step_count++;
  }
}

sub print_usage() {
  print <<HERE;
       Usage: wsrun.pl [options]  <top module name> <list of verilog files>

       Options:
                       [-wave] 
                       [-align]
                       [-compileonly]
                       [-do <do filename>] 
                       [-prog <assemble file to run>] 
                       [-addr <address trace file to use for mem_system_perfbench>] 
                       [-list <filename with list of assembly files>]
                       [-n <number of cycles to simulate>]
                       [-seed <random seed>]
                       [-help]
                       [-brief]
                        
HERE
}

sub hextobinary() {
  my ($c) = @_;
  my %hextobinary_map;
  $hextobinary_map{"0"} = "0000";
  $hextobinary_map{"1"} = "0001";
  $hextobinary_map{"2"} = "0010";
  $hextobinary_map{"3"} = "0011";
  $hextobinary_map{"4"} = "0100";
  $hextobinary_map{"5"} = "0101";
  $hextobinary_map{"6"} = "0110";
  $hextobinary_map{"7"} = "0111";
  $hextobinary_map{"8"} = "1000";
  $hextobinary_map{"9"} = "1001";
  $hextobinary_map{"a"} = "1010";
  $hextobinary_map{"b"} = "1011";
  $hextobinary_map{"c"} = "1100";
  $hextobinary_map{"d"} = "1101";
  $hextobinary_map{"e"} = "1110";
  $hextobinary_map{"f"} = "1111";

  my $i = 0;
  my $s = "";
  for ($i = 0 ; $i < length($c); $i++) {
  	my $x = substr($c, $i, 1);
	$s = $s." ".$hextobinary_map{$c};	
  }
  return $s; 
}
