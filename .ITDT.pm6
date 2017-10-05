#!/usr/bin/env perl6

use                 Hardware::Tape::Management::ITDT;

sub MAIN (
            Str     :$itdt-path,
            Str     :$media-changer,
            Str     :$whence,
            Bool    :$robots,
            Bool    :$drives,
            Bool    :$iestations,
            Bool    :$slots,
            Bool    :$states,
            Bool    :$volumes,
         ) {

    if ($states && $volumes) || ($states && $whence) || ($volumes && $whence) {
        note "$*PROGRAM-NAME: --media-changer=... --itdt-path=... [--robots] [--drives] [--iestations] [--slots] [--states | --volumes | --whence]";
        exit 2;
    }

    my %args;
    %args<itdt-path>     = $itdt-path     if $itdt-path;
    %args<media-changer> = $media-changer if $media-changer;

    my Hardware::Tape::Management::ITDT $tape_library_inventory .= new(|%args);

    if $whence {
        my $obj = $tape_library_inventory.WhenceVolume($whence);
        given $obj.^name {
            when /Robot/        { say "$whence is currently located in Robot " ~ $obj.RobotAddress; }
            when /Drive/        { say "$whence is currently located in Drive " ~ $obj.DriveAddress; }
            when /IEStation/    { say "$whence is currently located in IEStation " ~ $obj.ImportExportStationAddress; }
            when /Slot/         { say "$whence is currently located in Slot " ~ $obj.SlotAddress; }
        }
    }
    elsif $states {
        if $robots      { say $_.fmt("Robot %-5s %s") for $tape_library_inventory.RobotStates; }
        if $drives      { say $_.fmt("Drive %-5s %s") for $tape_library_inventory.DriveStates; }
        if $iestations  { say $_.fmt("Import/Export Station %-5s %s") for $tape_library_inventory.ImportExportStates; }
        if $slots       { say $_.fmt("Slot %-5s %s") for $tape_library_inventory.SlotStates; }
    }
    elsif $volumes {
        my @volumes;
        push(@volumes, $tape_library_inventory.DriveVolumes)                if $drives;
        push(@volumes, $tape_library_inventory.ImportExportStationVolumes)  if $iestations;
        push(@volumes, $tape_library_inventory.SlotVolumes)                 if $slots;
        say @volumes.words.sort.join("\n")                                  if @volumes.elems;
    }
    else {
        $tape_library_inventory.RobotSummaries      if $robots;
        $tape_library_inventory.DriveSummaries      if $drives;
        $tape_library_inventory.IEStationSummaries  if $iestations;
        $tape_library_inventory.SlotSummaries       if $slots;
    }
}

=finish
