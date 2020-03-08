use     Hardware::Tape::Management::ITDT::Robot;
use     Hardware::Tape::Management::ITDT::Drive;
use     Hardware::Tape::Management::ITDT::IEStation;
use     Hardware::Tape::Management::ITDT::Slot;
unit    grammar Hardware::Tape::Management::ITDT::Grammars::Inventory:api<1>:auth<Mark Devine (mark@markdevine.com)>;

token TOP {
    <preamble>
    <RobotStanza>+
    <DriveStanza>+
    <ImportExportStationStanza>+
    <SlotStanza>+
    <postamble>
}
token preamble { ^ 'Reading element status...' \n+ }
token RobotStanza {
    <RobotAddress>
    <RobotState>
    <ASCASCQ>
    <MediaPresent>
    <SourceElementAddressValid>
    <LocationFraColRowAcc>
    <MediaInverted>
    <VolumeTag>
    \n*
}
token DriveStanza {
    <DriveAddress>
    <DriveState>
    <ASCASCQ>
    <MediaPresent>
    <RobotAccessAllowed>
    <SourceElementAddressValid>
    <SourceElementAddress>?
    <LocationFraColRowAcc>?
    <MediaInverted>
    <SameBusasMediumChanger>
    <SCSIBusAddressValid>
    <LogicalUnitNumberValid>
    <VolumeTag>
    \n*
}
token ImportExportStationStanza {
    <ImportExportStationAddress>
    <ImportExportState>
    <ASCASCQ>
    <MediaPresent>
    <MediaPlacedbyOperator>?
    <ImportEnabled>
    <ExportEnabled>
    <RobotAccessAllowed>
    <SourceElementAddressValid>
    <LocationFraColRowAcc>
    <MediaInverted>
    <VolumeTag>
    \n*
}
token SlotStanza {
    <SlotAddress>
    <SlotState>
    <ASCASCQ>
    <MediaPresent>
    <RobotAccessAllowed>
    <SourceElementAddressValid>
    <LocationFraColRowAcc>
    <MediaInverted>
    <VolumeTag>
    \n*
}
token RobotAddress                  { ^^ 'Robot Address' \s $<v> = [ \d+ ] \n                              }
token RobotState                    { ^^ \s* 'Robot State' \s* '.'+ \s* $<v> = [ \w+ ] \n                  }
token DriveAddress                  { ^^ 'Drive Address' \s $<v> = [ \d+ ] \n                              }
token DriveState                    { ^^ \s* 'Drive State' \s* '.'+ \s+ $<v> = [ .+? ] \n                  }
token SameBusasMediumChanger        { ^^ \s* 'Same Bus as Medium Changer' \s* '.'+ \s+ $<v> = [ .+? ] \n   }
token SCSIBusAddressValid           { ^^ \s* 'SCSI Bus Address Valid' \s* '.'+ \s+ $<v> = [ .+? ] \n       }
token LogicalUnitNumberValid        { ^^ \s* 'Logical Unit Number Valid' \s* '.'+ \s+ $<v> = [ .+? ] \n    }
token ImportExportStationAddress    { ^^ 'Import/Export Station Address' \s $<v> = [ \d+ ] \n              }
token ImportExportState             { ^^ \s* 'Import/Export State' \s* '.'+ \s+ $<v> = [ .+? ] \n          }
token ImportEnabled                 { ^^ \s* 'Import Enabled' \s* '.'+ \s+ $<v> = [ .+? ] \n               }
token ExportEnabled                 { ^^ \s* 'Export Enabled' \s* '.'+ \s+ $<v> = [ .+? ] \n               }
token SlotAddress                   { ^^ 'Slot Address' \s* '.'+ \s* $<v> = [ \d+ ] \n                     }
token SlotState                     { ^^ \s* 'Slot State' \s* '.'+ \s+ $<v> = [ .+? ] \n                   }
token ASCASCQ                       { ^^ \s* 'ASC/ASCQ' \s* '.'+ \s+ $<v> = [ .+? ] \n                     }
token MediaPresent                  { ^^ \s* 'Media Present' \s* '.'+ \s* $<v> = [ \w+ ] \n                }
token MediaPlacedbyOperator         { ^^ \s* 'Media Placed by Operator' \s* '.'+ \s* $<v> = [ \w+ ] \n     }
token SourceElementAddressValid     { ^^ \s* 'Source Element Address Valid' \s* '.'+ \s+ $<v> = [ \w+ ] \n }
token SourceElementAddress          { ^^ \s* 'Source Element Address' \s* '.'+ \s* $<v> = [ .+? ] \n       }
token LocationFraColRowAcc          { ^^ \s* 'Location (Fra/Col/Row/Acc)' \s* '.'+ \s* $<v> = [.+?] \n     }
token MediaInverted                 { ^^ \s* 'Media Inverted' \s* '.'+ \s+ $<v> = [ \w+ ] \n               }
token RobotAccessAllowed            { ^^ \s* 'Robot Access Allowed' \s* '.'+ \s+ $<v> = [ \w+ ] \n         }
regex VolumeTag                     { ^^ \s* 'Volume Tag' \s* '.'+ \s* $<v> = [ \w* ] \n                   }
token postamble                     { \n* 'Exit with code:' \s+ \d+ \n*                                    }

class Actions {
    method RobotStanza ($/) {
        make Hardware::Tape::Management::ITDT::Robot.new(
            RobotAddress                => ~$/<RobotAddress><v>,
            RobotState                  => ~$/<RobotState><v>,
            ASCASCQ                     => ~$/<ASCASCQ><v>,
            MediaPresent                => ~$/<MediaPresent><v>,
            SourceElementAddressValid   => ~$/<SourceElementAddressValid><v>,
            LocationFraColRowAcc        => ~$/<LocationFraColRowAcc><v>,
            MediaInverted               => ~$/<MediaInverted><v>,
            VolumeTag                   => ~$/<VolumeTag><v>,
        );
    }
    method DriveStanza ($/) {
        my $SourceElementAddress;
        $SourceElementAddress           = ~$/<SourceElementAddress><v> if $/<SourceElementAddress>:exists;
        my $LocationFraColRowAcc;
        $LocationFraColRowAcc           = ~$/<LocationFraColRowAcc><v> if $/<LocationFraColRowAcc><v>:exists;
        make Hardware::Tape::Management::ITDT::Drive.new(
            DriveAddress                => ~$/<DriveAddress><v>,
            DriveState                  => ~$/<DriveState><v>,
            ASCASCQ                     => ~$/<ASCASCQ><v>,
            MediaPresent                => ~$/<MediaPresent><v>,
            RobotAccessAllowed          => ~$/<RobotAccessAllowed><v>,
            SourceElementAddressValid   => ~$/<SourceElementAddressValid><v>,
            SourceElementAddress        => $SourceElementAddress,
            LocationFraColRowAcc        => $LocationFraColRowAcc,
            MediaInverted               => ~$/<MediaInverted><v>,
            SameBusasMediumChanger      => ~$/<SameBusasMediumChanger><v>,
            SCSIBusAddressValid         => ~$/<SCSIBusAddressValid><v>,
            LogicalUnitNumberValid      => ~$/<LogicalUnitNumberValid><v>,
            VolumeTag                   => ~$/<VolumeTag><v>,
        );
    }
    method ImportExportStationStanza ($/) {
        my $SourceElementAddress;
        $SourceElementAddress           = ~$/<SourceElementAddress><v> if $/<SourceElementAddress>:exists;
        my $LocationFraColRowAcc;
        $LocationFraColRowAcc           = ~$/<LocationFraColRowAcc><v> if $/<LocationFraColRowAcc><v>:exists;
        my $MediaPlacedbyOperator;
        $MediaPlacedbyOperator          = ~$/<MediaPlacedbyOperator><v> if $/<MediaPlacedbyOperator><v>:exists;
        make Hardware::Tape::Management::ITDT::IEStation.new(
            ImportExportStationAddress  => ~$/<ImportExportStationAddress><v>,
            ImportExportState           => ~$/<ImportExportState><v>,
            ASCASCQ                     => ~$/<ASCASCQ><v>,
            MediaPresent                => ~$/<MediaPresent><v>,
            MediaPlacedbyOperator       => $MediaPlacedbyOperator,
            ImportEnabled               => ~$/<ImportEnabled><v>,
            ExportEnabled               => ~$/<ExportEnabled><v>,
            RobotAccessAllowed          => ~$/<RobotAccessAllowed><v>,
            SourceElementAddressValid   => ~$/<SourceElementAddressValid><v>,
            SourceElementAddress        => $SourceElementAddress,
            LocationFraColRowAcc        => $LocationFraColRowAcc,
            MediaInverted               => ~$/<MediaInverted><v>,
            VolumeTag                   => ~$/<VolumeTag><v>,
        );
    }
    method SlotStanza ($/) {
        make Hardware::Tape::Management::ITDT::Slot.new(
            SlotAddress                 => ~$/<SlotAddress><v>,
            SlotState                   => ~$/<SlotState><v>,
            ASCASCQ                     => ~$/<ASCASCQ><v>,
            MediaPresent                => ~$/<MediaPresent><v>,
            RobotAccessAllowed          => ~$/<RobotAccessAllowed><v>,
            SourceElementAddressValid   => ~$/<SourceElementAddressValid><v>,
            LocationFraColRowAcc        => ~$/<LocationFraColRowAcc><v>,
            MediaInverted               => ~$/<MediaInverted><v>,
            VolumeTag                   => ~$/<VolumeTag><v>,
        );
    }
}
