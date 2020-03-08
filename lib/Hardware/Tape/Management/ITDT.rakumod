=begin pod

=head1 Hardware::Tape::Management::ITDT

C<Hardware::Tape::Management::ITDT> is a module that reads IBM's Tape Diagnostic Tool.

=head1 Synopsis

    use Hardware::Tape::Management::ITDT;
    my Hardware::Tape::Management::ITDT $tape_library_inventory .= new(:media-changer</dev/smc0>);
    say $tape_library_inventory.RobotSummaries;

=end pod

unit    class Hardware::Tape::Management::ITDT:api<1>:auth<mark@markdevine.com>;

use     Hardware::Tape::Management::ITDT::Grammars::Inventory;
use     Hardware::Tape::Management::ITDT::Exceptions;
use     Hardware::Tape::Management::ITDT::Robot;
use     Hardware::Tape::Management::ITDT::Drive;
use     Hardware::Tape::Management::ITDT::IEStation;
use     Hardware::Tape::Management::ITDT::Slot;

has $.itdt-path     = '/opt/our/ITDT/itdt';
has $.media-changer = '/dev/IBMchanger0';

has %!Robot;
has %!Drive;
has %!IEStation;
has %!Slot;

submethod TWEAK {
    my $match_tree;
    X::Hardware::Tape::Management::ITDT::NSF.new(source => $!media-changer).throw() unless "$!media-changer".IO.e;
    my $proc = run 'sudo', self.itdt-path, '-w', 2, '-f', self.media-changer, 'inventory', :out;
    my $inventory = $proc.out.slurp: :close;
    $match_tree = Hardware::Tape::Management::ITDT::Grammars::Inventory.parse(
        $inventory,
        actions => Hardware::Tape::Management::ITDT::Grammars::Inventory::Actions,
    ) or X::Hardware::Tape::Management::ITDT::ParseFail.new(source => self.media-changer).throw;

    for keys $match_tree<RobotStanza> -> $robot_index {
        for $match_tree<RobotStanza>[$robot_index] -> $robot {
            my $address = ~$match_tree<RobotStanza>[$robot_index]<RobotAddress><v>;
            %!Robot{$address}       = $robot.made;
        }
    }
    for keys $match_tree<DriveStanza> -> $drive_index {
        for $match_tree<DriveStanza>[$drive_index] -> $drive {
            my $address = ~$match_tree<DriveStanza>[$drive_index]<DriveAddress><v>;
            %!Drive{$address}       = $drive.made;
        }
    }
    for keys $match_tree<ImportExportStationStanza> -> $iestation_index {
        for $match_tree<ImportExportStationStanza>[$iestation_index] -> $iestation {
            my $address = ~$match_tree<ImportExportStationStanza>[$iestation_index]<ImportExportStationAddress><v>;
            %!IEStation{$address}   = $iestation.made;
        }
    }
    for keys $match_tree<SlotStanza> -> $slot_index {
        for $match_tree<SlotStanza>[$slot_index] -> $slot {
            my $address = ~$match_tree<SlotStanza>[$slot_index]<SlotAddress><v>;
            %!Slot{$address}        = $slot.made;
        }
    }
}

method RobotAddresses               { return sort { $^a <=> $^b }, keys %!Robot; }
method RobotObjects                 { return self.RobotAddresses.flatmap: { %!Robot{$_} }; }
method RobotStates                  { return self.RobotAddresses.flatmap: { $_ => %!Robot{$_}.RobotState }; }
method RobotSummaries               { .PrintSummary for self.RobotObjects; }

method DriveAddresses               { return sort { $^a <=> $^b }, keys %!Drive; }
method DriveObjects                 { return self.DriveAddresses.flatmap: { %!Drive{$_} }; }
method DriveStates                  { return self.DriveAddresses.flatmap: { $_ => %!Drive{$_}.DriveState }; }
method DriveVolumes                 { return self.DriveObjects.grep({ $_ with .VolumeTag }).map: { .VolumeTag }; }
method DriveSummaries               { .PrintSummary for self.DriveObjects; }

method ImportExportStationAddresses { return sort { $^a <=> $^b }, keys %!IEStation; }
method ImportExportStationObjects   { return self.ImportExportStationAddresses.flatmap: { %!IEStation{$_} }; }
method ImportExportStates           { return self.ImportExportStationAddresses.flatmap: { $_ => %!IEStation{$_}.ImportExportState }; }
method ImportExportStationVolumes   { return self.ImportExportStationObjects.grep({ $_ with .VolumeTag }).map: { .VolumeTag }; }
method IEStationSummaries           { .PrintSummary for self.ImportExportStationObjects; }

method SlotAddresses                { return sort { $^a <=> $^b }, keys %!Slot; }
method SlotObjects                  { return self.SlotAddresses.flatmap: { %!Slot{$_} }; }
method SlotStates                   { return self.SlotAddresses.flatmap: { $_ => %!Slot{$_}.SlotState }; }
method SlotVolumes                  { return self.SlotObjects.grep({ $_ with .VolumeTag }).map: { .VolumeTag }; }
method SlotSummaries                { .PrintSummary for self.SlotObjects; }

method WhenceVolume (Str $volume_to_match) {
    for self.RobotObjects -> $robot {
        return $robot       if $robot.VolumeTag eq $volume_to_match;
    }
    for self.DriveObjects -> $drive {
        return $drive       if $drive.VolumeTag eq $volume_to_match;
    }
    for self.ImportExportStationObjects -> $iestation {
        return $iestation   if $iestation.VolumeTag eq $volume_to_match;
    }
    for self.SlotObjects -> $slot {
        return $slot        if $slot.VolumeTag eq $volume_to_match;
    }
    return;
}

=finish

<test script>

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

</test script>

<sample test script executions>
    ./.ITDT.pm6 --media-changer=inventory.itdt --drives --volumes
    ./.ITDT.pm6 --media-changer=inventory.itdt --whence=230567JA
    ./.ITDT.pm6 --media-changer=inventory.itdt --robots --states
</sample test script executions>
