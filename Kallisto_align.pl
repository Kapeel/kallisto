#!/usr/bin/perl -w
use strict;
use File::Basename;
use Data::Dumper;
use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);


my (@file_query, $database_path, $user_database_path, $annotation_path, 
$user_annotation_path, $file_names, $root_names, @file_query2, $file_type, $lib_type);


GetOptions( "file_query=s"      => \@file_query,
	    "file_query2=s"     => \@file_query2,
	    "user_database=s"   => \$user_database_path,
	    "file_type=s"       => \$file_type
	    );

# sanity check for input data
if (@file_query2) {
    @file_query && @file_query2 || die "Error: At least one file for each paired-end is required\n"; 
    @file_query == @file_query2 || die "Error: Unequal number of files for paired ends\n";
}

if (!($user_database_path || $database_path)) {
    die "No reference set of transcripts was supplied\n";
}
if (@file_query < 1) {
    die "No FASTQ files were supplied\n";
}


# Allow over-ride of system-level database path with user
#my $kallisto  = "kallisto_linux-v0.43.1/kallisto";

if ($user_database_path) {
  $database_path = $user_database_path;
  unless (`grep \\> $database_path`) {
      die "Error: $database_path the user supplied file is not a FASTA file";
  }
  my $name = basename($database_path, qw/.fa .fas .fasta .fna .fa.gz .fasta.gz/);
  print STDERR "kallisto-indexing $name\n";
  system "kallisto index -i $database_path.index $database_path";
 } 
#  if ($database_path !~ /$name\.fa$/) {
#      my $new_path = $database_path;
#      $new_path =~ s/$name\.\S+$/$name\.fa/;
      #system "cp $database_path $new_path";
#  }
#  $database_path = $name;
#}


my $success = undef;

system "mkdir kallisto_qaunt_output";

for my $query_file (@file_query) {
    # Grab any flags or options we don't recognize and pass them as plain text
    # Need to filter out options that are handled by the GetOptions call
    my @args_to_reject = qw(-xxxx);


    my $second_file = shift @file_query2 if @file_query2;

    my $KALLISTO_ARGS = join(" ", @ARGV);
    foreach my $a (@args_to_reject) {
	if ($KALLISTO_ARGS =~ /$a/) {
	    report("Most Kallisto arguments are legal for use with this script, but $a is not. Please omit it and submit again");
	    exit 1;
	}
    }

# Check for presence of second read file
#if (defined($second_file)) {
#       $format = 'PE';
#       report("Pair-end alignment requested");
#}

my $format = $file_type;


chomp(my $basename = `basename $query_file`);
    $basename =~ s/\.\S+$//;

if ($format eq 'PE') {
          my $align_command = "kallisto quant -i $database_path.index -o $basename $KALLISTO_ARGS $query_file $second_file | samtools view -bS - > $basename.bam";
          system $align_command;
	  my $mv_out = "mv $basename.bam $basename; mv $basename kallisto_qaunt_output";
	  #my $mv_out = "mv $basename kallisto_qaunt_output";
	  system $mv_out;          
           } 
elsif($format eq 'SE'){
          my $align_command = "kallisto quant -i $database_path.index -o $basename $KALLISTO_ARGS --single -r $query_file | samtools view -bS - > $basename.bam";
          system $align_command;
	  my $mv_out2 = "mv $basename.bam $basename; mv $basename kallisto_qaunt_output";
	#my $mv_out2 = "mv $basename kallisto_qaunt_output";
          system $mv_out2;        
        	}
   	}


sub report {
    print STDERR "$_[0]\n";
}

sub report_input_stack {
    my @stack = @ARGV;
    report(Dumper \@stack);
}
