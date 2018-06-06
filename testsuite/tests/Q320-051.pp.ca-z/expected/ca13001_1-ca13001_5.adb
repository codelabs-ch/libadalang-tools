--==================================================================--

with Ca13001_1.Ca13001_2.Ca13001_4;   -- Public grandchild of a private parent,
-- implicitly with CA13001_1.CA13001_2.
package body Ca13001_1.Ca13001_5 is

   package Transportation_Pkg renames Ca13001_1.Ca13001_2.Ca13001_4;
   use Transportation_Pkg;

   -- These two validation subprograms provide the capability to check the
   -- components defined in the private packages from within the client
   -- program.

   procedure Provide_Transportation
     (Who : in Family; Get_Key : out Key_Type; Get_Veh : out Boolean)
   is
   begin
      -- Goto work, school, or to the beach.
      Family_Transportation.Get_Vehicle (Who, Get_Key);
      if not Family_Transportation.Tc_Verify (Transportation'Val (Get_Key))
      then
         Get_Veh := True;
      else
         Get_Veh := False;
      end if;

   end Provide_Transportation;

   ----------------------------------------------------------------

   procedure Return_Transportation
     (What : in Transportation; Rt_Veh : out Boolean)
   is
   begin
      Family_Transportation.Return_Vehicle (What);
      if Family_Transportation.Tc_Verify (What) and
        not Ca13001_1.Ca13001_2.Vehicles (What).In_Use then
         Rt_Veh := True;
      else
         Rt_Veh := False;
      end if;

   end Return_Transportation;

end Ca13001_1.Ca13001_5;
