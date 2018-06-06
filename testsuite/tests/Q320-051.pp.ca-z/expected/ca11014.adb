-- Points list operation.

     --==================================================================--

with Ca11014_1.Ca11014_2;      -- Additional generic list operation,
-- implicitly with list operation.
with Ca11014_3;                -- Package containing discrete type declaration.
with Ca11014_4;                -- Points list.
with Ca11014_5.Ca11014_6;      -- Points list operation.
with Report;

procedure Ca11014 is

   package Lists_Of_Scores renames Ca11014_4;
   package Score_Ops renames Ca11014_5;
   package Point_Ops renames Ca11014_5.Ca11014_6;

   Scores : Lists_Of_Scores.List_Type;                -- List of points.

   type Tc_Score_Array is array (1 .. 3) of Ca11014_3.Points;

   Tc_Initial_Values : constant Tc_Score_Array := (10, 21, 49);
   Tc_Final_Values   : constant Tc_Score_Array := (0, 0, 0);

   Tc_Initial_Values_Are_Correct : Boolean := False;
   Tc_Final_Values_Are_Correct   : Boolean := False;

   --------------------------------------------------

   -- Initial list contains 3 scores with the values 10, 21, and 49.
   procedure Tc_Initialize_List (L : in out Lists_Of_Scores.List_Type) is
   begin
      for I in Tc_Score_Array'Range loop
         Score_Ops.Add_Element (L, Tc_Initial_Values (I));
         -- Operation from generic parent.
      end loop;
   end Tc_Initialize_List;

   --------------------------------------------------

   -- Verify that all scores have been set to zero.
   procedure Tc_Verify_List
     (L  : in out Lists_Of_Scores.List_Type; Expected : in Tc_Score_Array;
      Ok :    out Boolean)
   is
      Actual : Tc_Score_Array;
   begin
      Lists_Of_Scores.Reset (L);       -- Operation from parent's formal.
      for I in Tc_Score_Array'Range loop
         Score_Ops.Read_Element (L, Actual (I));
         -- Operation from generic parent.
      end loop;
      Ok := (Actual = Expected);
   end Tc_Verify_List;

   --------------------------------------------------

begin -- CA11014

   Report.Test
     ("CA11014",
      "Check that an instantiation of a child package " &
      "of a generic package can use its parent's " &
      "declarations and operations, including a " &
      "formal package of the parent");

   Tc_Initialize_List (Scores);
   Tc_Verify_List (Scores, Tc_Initial_Values, Tc_Initial_Values_Are_Correct);

   if not Tc_Initial_Values_Are_Correct then
      Report.Failed ("List contains incorrect initial values");
   end if;

   Point_Ops.Write_First_To_List (Scores);
   -- Operation from generic child package.

   Tc_Verify_List (Scores, Tc_Final_Values, Tc_Final_Values_Are_Correct);

   if not Tc_Final_Values_Are_Correct then
      Report.Failed ("List contains incorrect final values");
   end if;

   Report.Result;

end Ca11014;
