unit        class Hardware::Tape::Management::ITDT;

use         v6;
use         Hardware::Tape::Management::ITDT::Grammars::Inventory;
use         Hardware::Tape::Management::ITDT::Exceptions;
use         Hardware::Tape::Management::ITDT::Robot;
use         Hardware::Tape::Management::ITDT::Drive;
use         Hardware::Tape::Management::ITDT::IEStation;
use         Hardware::Tape::Management::ITDT::Slot;

has $.itdt_path;
has $.media_changer;

has %!Robot;
has %!Drive;
has %!IEStation;
has %!Slot;

submethod BUILD (:$!media_changer, :$!itdt_path) {

    $!media_changer = '/dev/IBMchanger0'    unless $!media_changer.defined;
    $!itdt_path     = '/opt/our/ITDT/itdt'  unless $!itdt_path.defined;

    my $match_tree;
    X::Hardware::Tape::Management::ITDT::NSF.new(source => $!media_changer).throw() unless "$!media_changer".IO.e;
    my $proc = run 'sudo', self.itdt_path, '-w', 2, '-f', self.media_changer, 'inventory', :out;
    my $inventory = $proc.out.slurp: :close;
    $match_tree = Hardware::Tape::Management::ITDT::Grammars::Inventory.parse(
        $inventory,
        actions => Hardware::Tape::Management::ITDT::Grammars::Inventory::Actions,
    ) or X::Hardware::Tape::Management::ITDT::ParseFail.new(source => self.media_changer).throw;

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
method DriveVolumes {
    my @vols;
    for self.DriveObjects -> $drive {
        push(@vols, $drive.VolumeTag) if $drive.VolumeTag;
    }
    return @vols;
}
method DriveSummaries               { .PrintSummary for self.DriveObjects; }

method ImportExportStationAddresses { return sort { $^a <=> $^b }, keys %!IEStation; }
method ImportExportStationObjects   { return self.ImportExportStationAddresses.flatmap: { %!IEStation{$_} }; }
method ImportExportStates           { return self.ImportExportStationAddresses.flatmap: { $_ => %!IEStation{$_}.ImportExportState }; }
method ImportExportStationVolumes {
    my @vols;
    for self.ImportExportStationObjects -> $iestation {
        push(@vols, $iestation.VolumeTag) if $iestation.VolumeTag;
    }
    return @vols;
}
method IEStationSummaries           { .PrintSummary for self.ImportExportStationObjects; }

method SlotAddresses                { return sort { $^a <=> $^b }, keys %!Slot; }
method SlotObjects                  { return self.SlotAddresses.flatmap: { %!Slot{$_} }; }
method SlotStates                   { return self.SlotAddresses.flatmap: { $_ => %!Slot{$_}.SlotState }; }
method SlotVolumes {
    my @vols;
    for self.SlotObjects -> $slot {
        push(@vols, $slot.VolumeTag) if $slot.VolumeTag;
    }
    return @vols;
}
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

=begin pod

=head1 Hardware::Tape::Management::ITDT

C<Hardware::Tape::Management::ITDT> is a module that reads IBM's Tape Diagnostic Tool.

=head1 Synopsis

    use Hardware::Tape::Management::ITDT;

    my Hardware::Tape::Management::ITDT $tape_library_inventory .= new(:media_changer</dev/smc0>);

    say $tape_library_inventory.Robots;

    my @volumes;
    for $tape_library_inventory.IEStations -> $iestation {
        push(@volumes, $tape_library_inventory.IEStationVolumeTag($iestation))
          if $tape_library_inventory.IEStationVolumeTag($iestation);
    }

=end pod

=begin test script
    #!/usr/bin/env perl6

    use                 v6;
    use                 Hardware::Tape::Management::ITDT;

    sub MAIN (
                Str     :$media_changer,
                Str     :$itdt_path,
                Str     :$whence,
                Bool    :$robots,
                Bool    :$drives,
                Bool    :$iestations,
                Bool    :$slots,
                Bool    :$states,
                Bool    :$volumes,
            ) {

        if ($states && $volumes) || ($states && $whence) || ($volumes && $whence) {
            die "$*PROGRAM-NAME [--states | --volumes | --whence]";
        }

        my Hardware::Tape::Management::ITDT $tape_library_inventory .= new(:$media_changer, :$itdt_path);

        if $whence {
            my $obj = $tape_library_inventory.WhenceVolume($whence);
            given $obj.^name {
                when /Robot/        { say "$whence is currently located in Robot     " ~ $obj.RobotAddress; }
                when /Drive/        { say "$whence is currently located in Drive     " ~ $obj.DriveAddress; }
                when /IEStation/    { say "$whence is currently located in IEStation " ~ $obj.ImportExportStationAddress; }
                when /Slot/         { say "$whence is currently located in Slot      " ~ $obj.SlotAddress; }
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
=end test script
