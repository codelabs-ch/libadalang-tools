with Cxa40140;
with Ada.Strings.Wide_Fixed;
with Ada.Strings.Wide_Maps;
with Report;

procedure Cxa4014 is
   use Cxa40140;
begin

   Report.Test
     ("CXA4014",
      "Check that the subprograms defined in package " &
      "Ada.Strings.Wide_Fixed are available, and that " &
      "they produce correct results");

   Test_Block :
   declare

      Number_Of_Info_Strings : constant Natural     := 3;
      Db_Size                : constant Natural     := Number_Of_Info_Strings;
      Count                  : Natural              := 0;
      Finished_Processing    : Boolean              := False;
      Blank_Wide_String      : constant Wide_String := " ";

      subtype Info_Wide_String_Type is Wide_String (1 .. 50);
      type Info_Wide_String_Storage_Type is
        array (1 .. Number_Of_Info_Strings) of Info_Wide_String_Type;

      subtype Name_Type is Wide_String (1 .. 10);
      subtype Street_Number_Type is Wide_String (1 .. 5);
      subtype Street_Name_Type is Wide_String (1 .. 10);
      subtype City_Type is Wide_String (1 .. 10);
      subtype State_Type is Wide_String (1 .. 2);
      subtype Zip_Code_Type is Wide_String (1 .. 5);

      type Data_Base_Element_Type is record
         Name          : Name_Type          := (others => ' ');
         Street_Number : Street_Number_Type := (others => ' ');
         Street_Name   : Street_Name_Type   := (others => ' ');
         City          : City_Type          := (others => ' ');
         State         : State_Type         := (others => ' ');
         Zip_Code      : Zip_Code_Type      := (others => ' ');
      end record;

      type Data_Base_Type is array (1 .. Db_Size) of Data_Base_Element_Type;

      Data_Base : Data_Base_Type;

      ---

      Info_String_1 : Info_Wide_String_Type :=
        "Joe_Jones 123   Sixth_St   San_Diego    CA   98765";

      Info_String_2 : Info_Wide_String_Type :=
        "Sam_Smith 56789  S._Seventh   Carlsbad  CA   92177";

      Info_String_3 : Info_Wide_String_Type :=
        "Jane_Brown 1219   Info_Lane  Tuscon     AZ   85643";

      Info_Strings : Info_Wide_String_Storage_Type :=
        (1 => Info_String_1, 2 => Info_String_2, 3 => Info_String_3);

      Tc_Db_Element_1 : Data_Base_Element_Type :=
        ("Joe Jones ", "123  ", "Sixth St  ", "San Diego ", "CA", "98765");

      Tc_Db_Element_2 : Data_Base_Element_Type :=
        ("Sam Smith ", "56789", "S. Seventh", "Carlsbad  ", "CA", "92177");

      Tc_Db_Element_3 : Data_Base_Element_Type :=
        ("Jane Brown", "1219 ", "Info Lane ", "Tuscon    ", "AZ", "85643");

      Tc_Data_Base : Data_Base_Type :=
        (Tc_Db_Element_1, Tc_Db_Element_2, Tc_Db_Element_3);

      ---

      procedure Store_Information
        (Info_String : in     Info_Wide_String_Type;
         Db_Record   : in out Data_Base_Element_Type)
      is

         package As renames Ada.Strings;
         use type As.Wide_Maps.Wide_Character_Set;

         Start, Stop : Natural := 0;

         Numeric_Set : constant As.Wide_Maps.Wide_Character_Set :=
           As.Wide_Maps.To_Set ("0123456789");

         Cal : constant As.Wide_Maps.Wide_Character_Sequence := "CA";
         California_Set : constant As.Wide_Maps.Wide_Character_Set      :=
           As.Wide_Maps.To_Set (Cal);
         Arizona_Set : constant As.Wide_Maps.Wide_Character_Set :=
           As.Wide_Maps.To_Set ("AZ");
         Nevada_Set : constant As.Wide_Maps.Wide_Character_Set :=
           As.Wide_Maps.To_Set ("NV");

         Blank_Ftn_Ptr : As.Wide_Maps.Wide_Character_Mapping_Function :=
           Us_To_Blank_Map'Access;

      begin

         -- Find the starting position of the name field (first non-blank),
         -- then, from that position, find the end of the name field (first
         -- blank).

         Start := As.Wide_Fixed.Index_Non_Blank (Info_String);
         Stop  :=
           As.Wide_Fixed.Index
             (Info_String (Start .. Info_String'Length),
              As.Wide_Maps.To_Set (Blank), As.Inside, As.Forward) -
           1;

         -- Store the name field in the data base element field for "Name".

         Db_Record.Name :=
           As.Wide_Fixed.Head (Info_String (1 .. Stop), Db_Record.Name'Length);

         -- Replace any underscore characters in the name field that were used
         -- to separate first/middle/last names. Use the overloaded version of
         -- Translate that takes an access-to-subprogram value.

         As.Wide_Fixed.Translate (Db_Record.Name, Blank_Ftn_Ptr);

         -- Continue the extraction process; now find the position of the
         -- street number in the string.

         Start := Stop + 1;

         As.Wide_Fixed.Find_Token
           (Info_String (Start .. Info_String'Length), Numeric_Set, As.Inside,
            Start, Stop);

         -- Store the street number field in the appropriate data base element.
         -- No modification of the default parameters of procedure Move is
         -- required.

         As.Wide_Fixed.Move
           (Source => Info_String (Start .. Stop),
            Target => Db_Record.Street_Number);

         -- Continue the extraction process; find the street name in the info
         -- string. Skip blanks to the start of the street name, then search
         -- for the index of the next blank character in the string.

         Start :=
           As.Wide_Fixed.Index_Non_Blank
             (Info_String (Stop + 1 .. Info_String'Length));

         Stop :=
           As.Wide_Fixed.Index
             (Info_String (Start .. Info_String'Length), Blank_Wide_String) -
           1;

         -- Store the street name in the appropriate data base element field.

         As.Wide_Fixed.Overwrite
           (Db_Record.Street_Name, 1, Info_String (Start .. Stop));

         -- Replace any underscore characters in the street name field
         -- that were used as word separation with blanks. Again, use
         -- the access-to-subprogram value to provide the mapping.

         Db_Record.Street_Name :=
           As.Wide_Fixed.Translate (Db_Record.Street_Name, Blank_Ftn_Ptr);

         -- Continue the extraction; remove the city name from the string.

         Start :=
           As.Wide_Fixed.Index_Non_Blank
             (Info_String (Stop + 1 .. Info_String'Length));

         Stop :=
           As.Wide_Fixed.Index
             (Info_String (Start .. Info_String'Length), Blank_Wide_String) -
           1;

         -- Store the city name field in the appropriate data base element.

         As.Wide_Fixed.Replace_Slice
           (Db_Record.City, 1, Db_Record.City'Length,
            Info_String (Start .. Stop));

         -- Replace any underscore characters in the city name field that were
         -- used as word separation.

         As.Wide_Fixed.Translate (Db_Record.City, Blank_Ftn_Ptr);

         -- Continue the extraction; remove the state identifier from the info
         -- string.

         Start := Stop + 1;

         As.Wide_Fixed.Find_Token
           (Info_String (Start .. Info_String'Length),
            As.Wide_Maps."OR"
              (California_Set, As.Wide_Maps."OR" (Nevada_Set, Arizona_Set)),
            As.Inside, Start, Stop);

         -- Store the state indicator into the data base element.

         As.Wide_Fixed.Move
           (Source => Info_String (Start .. Stop), Target => Db_Record.State,
            Drop   => Ada.Strings.Right, Justify => Ada.Strings.Left,
            Pad    => As.Wide_Space);

         -- Continue the extraction process; remove the final data item in the
         -- info string, the zip code, and place it into the corresponding data
         -- base element.

         Db_Record.Zip_Code :=
           As.Wide_Fixed.Tail (Info_String, Db_Record.Zip_Code'Length);

      exception
         when As.Length_Error =>
            Report.Failed ("Length_Error raised in procedure");
         when As.Pattern_Error =>
            Report.Failed ("Pattern_Error raised in procedure");
         when As.Translation_Error =>
            Report.Failed ("Translation_Error raised in procedure");
         when others =>
            Report.Failed ("Exception raised in procedure");
      end Store_Information;

   begin

      -- Loop thru the information strings, extract the name and address
      -- information, place this info into elements of the data base.

      while not Finished_Processing loop

         Count := Count + 1;

         Store_Information (Info_Strings (Count), Data_Base (Count));

         Finished_Processing := (Count = Number_Of_Info_Strings);

      end loop;

      -- Verify that the string processing was successful.

      for I in 1 .. Db_Size loop
         if Data_Base (I) /= Tc_Data_Base (I) then
            Report.Failed
              ("Data processing error on record " & Integer'Image (I));
         end if;
      end loop;

   exception
      when others =>
         Report.Failed ("Exception raised in Test_Block");
   end Test_Block;

   Report.Result;

end Cxa4014;
