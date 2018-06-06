-----------------------------------------------------------------------------

with Cxe4006_Common; use Cxe4006_Common;
with Cxe4006_Part_A1;
package Cxe4006_Part_A2 is
   pragma Remote_Call_Interface;

   subtype String_20 is String (1 .. 20);

   -- tagged types that can be passed between partitions
   type A2_Tagged_Type is new Root_Tagged_Type with record
      A2_Component : String_20;
   end record;

   procedure Single_Controlling_Operand
     (Rtt    : in out A2_Tagged_Type; Test_Number : in Integer;
      Callee :    out Type_Decl_Location);

   -- pass thru procedure
   procedure Call_B
     (X      : in out Root_Tagged_Type'Class; Test_Number : in Integer;
      Callee :    out Type_Decl_Location);
end Cxe4006_Part_A2;
