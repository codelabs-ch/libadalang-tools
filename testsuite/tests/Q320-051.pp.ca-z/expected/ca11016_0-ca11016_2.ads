     --==================================================================--

-- Map display operation, public child of physical map.

package Ca11016_0.Ca11016_2 is

   -- Super-duper Ultra Geographic Display Device (SDUGD) can display
   -- geographic locations with light intensity values ranging from 1 to 7.

   type Display_Val is range 1 .. 7;

   type Device_Color is (Brown, Blue, Green);

   type Io_Packet is record
      Lat       : Latitude;       -- Parent's type.
      Long      : Longitude;      -- Parent's type.
      Color     : Device_Color;
      Intensity : Display_Val;
   end record;

   procedure Data_For_Sdugd
     (Lat           : in     Latitude; Long : in Longitude;
      Output_Packet : in out Io_Packet);

end Ca11016_0.Ca11016_2;
