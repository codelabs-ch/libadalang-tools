-- CDD2A01.A
--
--                             Grant of Unlimited Rights
--
--     The Ada Conformity Assessment Authority (ACAA) holds unlimited
--     rights in the software and documentation contained herein. Unlimited
--     rights are the same as those granted by the U.S. Government for older
--     parts of the Ada Conformity Assessment Test Suite, and are defined
--     in DFAR 252.227-7013(a)(19). By making this public release, the ACAA
--     intends to confer upon all recipients unlimited rights equal to those
--     held by the ACAA. These rights include rights to use, duplicate,
--     release or disclose the released technical data and computer software
--     in whole or in part, in any manner and for any purpose whatsoever, and
--     to have or permit others to do so.
--
--                                    DISCLAIMER
--
--     ALL MATERIALS OR INFORMATION HEREIN RELEASED, MADE AVAILABLE OR
--     DISCLOSED ARE AS IS.  THE GOVERNMENT MAKES NO EXPRESS OR IMPLIED
--     WARRANTY AS TO ANY MATTER WHATSOEVER, INCLUDING THE CONDITIONS OF THE
--     SOFTWARE, DOCUMENTATION OR OTHER INFORMATION RELEASED, MADE AVAILABLE
--     OR DISCLOSED, OR THE OWNERSHIP, MERCHANTABILITY, OR FITNESS FOR A
--     PARTICULAR PURPOSE OF SAID MATERIAL.
--*
--
-- OBJECTIVE:
--    Check that the Read and Write attributes for a type extension are created
--    from the parent type's attribute (which may be user-defined) and those
--    for the extension components.  Also check that the default Input and
--    Output attributes are used for a type extension, even if the parent
--    type's attribute is user-defined.  (Defect Report 8652/0040,
--     as reflected in Technical Corrigendum 1, penultimate sentence of
--     13.13.2(9/1) and 13.13.2(25/1)).
--
-- CHANGE HISTORY:
--    30 JUL 2001   PHL   Initial version.
--     5 DEC 2001   RLB   Reformatted for ACATS.
--
--!
with Ada.Streams; use Ada.Streams;
with Fdd2a00;     use Fdd2a00;
with Report;      use Report;
procedure Cdd2a01 is

   Input_Output_Error : exception;

   type Int is range 1 .. 1_000;
   type Str is array (Int range <>) of Character;

   procedure Read
     (Stream : access Root_Stream_Type'Class; Item : out Int'Base);
   procedure Write (Stream : access Root_Stream_Type'Class; Item : Int'Base);
   function Input (Stream : access Root_Stream_Type'Class) return Int'Base;
   procedure Output (Stream : access Root_Stream_Type'Class; Item : Int'Base);

   for Int'Read use Read;
   for Int'Write use Write;
   for Int'Input use Input;
   for Int'Output use Output;

   type Parent (D1, D2 : Int; B : Boolean) is tagged record
      S : Str (D1 .. D2);
      case B is
         when False =>
            C1 : Integer;
         when True =>
            C2 : Float;
      end case;
   end record;

   procedure Read (Stream : access Root_Stream_Type'Class; Item : out Parent);
   procedure Write (Stream : access Root_Stream_Type'Class; Item : Parent);
   function Input (Stream : access Root_Stream_Type'Class) return Parent;
   procedure Output (Stream : access Root_Stream_Type'Class; Item : Parent);

   for Parent'Read use Read;
   for Parent'Write use Write;
   for Parent'Input use Input;
   for Parent'Output use Output;

   procedure Actual_Read
     (Stream : access Root_Stream_Type'Class; Item : out Int)
   is
   begin
      Integer'Read (Stream, Integer (Item));
   end Actual_Read;

   procedure Actual_Write (Stream : access Root_Stream_Type'Class; Item : Int)
   is
   begin
      Integer'Write (Stream, Integer (Item));
   end Actual_Write;

   function Actual_Input (Stream : access Root_Stream_Type'Class) return Int is
   begin
      return Int (Integer'Input (Stream));
   end Actual_Input;

   procedure Actual_Output (Stream : access Root_Stream_Type'Class; Item : Int)
   is
   begin
      Integer'Output (Stream, Integer (Item));
   end Actual_Output;

   procedure Actual_Read
     (Stream : access Root_Stream_Type'Class; Item : out Parent)
   is
   begin
      case Item.B is
         when False =>
            Item.C1 := 7;
         when True =>
            Float'Read (Stream, Item.C2);
      end case;
      Str'Read (Stream, Item.S);
   end Actual_Read;

   procedure Actual_Write
     (Stream : access Root_Stream_Type'Class; Item : Parent)
   is
   begin
      case Item.B is
         when False =>
            null; -- Don't write C1
         when True =>
            Float'Write (Stream, Item.C2);
      end case;
      Str'Write (Stream, Item.S);
   end Actual_Write;

   function Actual_Input (Stream : access Root_Stream_Type'Class) return Parent
   is
      X : Parent (1, 1, True);
   begin
      raise Input_Output_Error;
      return X;
   end Actual_Input;

   procedure Actual_Output
     (Stream : access Root_Stream_Type'Class; Item : Parent)
   is
   begin
      raise Input_Output_Error;
   end Actual_Output;

   package Int_Ops is new Counting_Stream_Ops (T => Int'Base,
      Actual_Write => Actual_Write, Actual_Input => Actual_Input,
      Actual_Read => Actual_Read, Actual_Output => Actual_Output);

   package Parent_Ops is new Counting_Stream_Ops (T => Parent,
      Actual_Write => Actual_Write, Actual_Input => Actual_Input,
      Actual_Read => Actual_Read, Actual_Output => Actual_Output);

   procedure Read
     (Stream : access Root_Stream_Type'Class; Item : out Int'Base) renames
     Int_Ops.Read;
   procedure Write
     (Stream : access Root_Stream_Type'Class; Item : Int'Base) renames
     Int_Ops.Write;
   function Input
     (Stream : access Root_Stream_Type'Class) return Int'Base renames
     Int_Ops.Input;
   procedure Output
     (Stream : access Root_Stream_Type'Class; Item : Int'Base) renames
     Int_Ops.Output;

   procedure Read
     (Stream : access Root_Stream_Type'Class; Item : out Parent) renames
     Parent_Ops.Read;
   procedure Write
     (Stream : access Root_Stream_Type'Class; Item : Parent) renames
     Parent_Ops.Write;
   function Input
     (Stream : access Root_Stream_Type'Class) return Parent renames
     Parent_Ops.Input;
   procedure Output
     (Stream : access Root_Stream_Type'Class; Item : Parent) renames
     Parent_Ops.Output;

   type Derived1 is new Parent with record
      C3 : Int;
   end record;

   type Derived2 (D : Int) is new Parent (D1 => D, D2 => D, B => False) with
   record
      C3 : Int;
   end record;

begin
   Test
     ("CDD2A01",
      "Check that the Read and Write attributes for a type " &
      "extension are created from the parent type's " &
      "attribute (which may be user-defined) and those for the " &
      "extension components; also check that the default input " &
      "and output attributes are used for a type extension, even " &
      "if the parent type's attribute is user-defined");

   Test1 :
   declare
      S  : aliased My_Stream (1_000);
      X1 : Derived1 (D1 => Int (Ident_Int (2)), D2 => Int (Ident_Int (5)),
         B => Ident_Bool (True));
      Y1 : Derived1 :=
        (D1 => 3, D2 => 6, B => False, S => Str (Ident_Str ("3456")),
         C1 => Ident_Int (100), C3 => Int (Ident_Int (88)));
      X2 : Derived1 (D1 => Int (Ident_Int (2)), D2 => Int (Ident_Int (5)),
         B => Ident_Bool (True));
   begin
      X1.S  := Str (Ident_Str ("bcde"));
      X1.C2 := Float (Ident_Int (4));
      X1.C3 := Int (Ident_Int (99));

      Derived1'Write (S'Access, X1);
      if Int_Ops.Get_Counts /= (Read => 0, Write => 1, Input => 0, Output => 0)
      then
         Failed ("Error writing extension components - 1");
      end if;
      if Parent_Ops.Get_Counts /=
        (Read => 0, Write => 1, Input => 0, Output => 0) then
         Failed ("Didn't call parent type's Write - 1");
      end if;

      Derived1'Read (S'Access, X2);
      if Int_Ops.Get_Counts /= (Read => 1, Write => 1, Input => 0, Output => 0)
      then
         Failed ("Error reading extension components - 1");
      end if;
      if Parent_Ops.Get_Counts /=
        (Read => 1, Write => 1, Input => 0, Output => 0) then
         Failed ("Didn't call inherited Read - 1");
      end if;

      if X2 /=
        (D1 => 2, D2 => 5, B => True, S => Str (Ident_Str ("bcde")),
         C2 => Float (Ident_Int (4)), C3 => Int (Ident_Int (99)))
      then
         Failed
           ("Inherited Read and Write are not inverses of each other - 1");
      end if;

      begin
         Derived1'Output (S'Access, Y1);
         if Int_Ops.Get_Counts /=
           (Read => 1, Write => 4, Input => 0, Output => 0) then
            Failed ("Error writing extension components - 2");
         end if;
         if Parent_Ops.Get_Counts /=
           (Read => 1, Write => 2, Input => 0, Output => 0) then
            Failed ("Didn't call inherited Write - 2");
         end if;
      exception
         when Input_Output_Error =>
            Failed ("Did call inherited Output - 2");
      end;

      begin
         declare
            Y2 : Derived1 := Derived1'Input (S'Access);
         begin
            if Int_Ops.Get_Counts /=
              (Read => 4, Write => 4, Input => 0, Output => 0) then
               Failed ("Error reading extension components - 2");
            end if;
            if Parent_Ops.Get_Counts /=
              (Read => 2, Write => 2, Input => 0, Output => 0) then
               Failed ("Didn't call inherited Read - 2");
            end if;
            if Y2 /=
              (D1 => 3, D2 => 6, B => False, S => Str (Ident_Str ("3456")),
               C1 => Ident_Int (7), C3 => Int (Ident_Int (88)))
            then
               Failed ("Input and Output are not inverses of each other - 2");
            end if;
         end;
      exception
         when Input_Output_Error =>
            Failed ("Did call inherited Input - 2");
      end;

   end Test1;

   Test2 :
   declare
      S  : aliased My_Stream (1_000);
      X1 : Derived2 (D => Int (Ident_Int (7)));
      Y1 : Derived2 :=
        (D  => 8, S => Str (Ident_Str ("8")), C1 => Ident_Int (200),
         C3 => Int (Ident_Int (77)));
      X2 : Derived2 (D => Int (Ident_Int (7)));
   begin
      X1.S  := Str (Ident_Str ("g"));
      X1.C1 := Ident_Int (4);
      X1.C3 := Int (Ident_Int (666));

      Derived2'Write (S'Access, X1);
      if Int_Ops.Get_Counts /= (Read => 4, Write => 5, Input => 0, Output => 0)
      then
         Failed ("Error writing extension components - 3");
      end if;
      if Parent_Ops.Get_Counts /=
        (Read => 2, Write => 3, Input => 0, Output => 0) then
         Failed ("Didn't call inherited Write - 3");
      end if;

      Derived2'Read (S'Access, X2);
      if Int_Ops.Get_Counts /= (Read => 5, Write => 5, Input => 0, Output => 0)
      then
         Failed ("Error reading extension components - 3");
      end if;
      if Parent_Ops.Get_Counts /=
        (Read => 3, Write => 3, Input => 0, Output => 0) then
         Failed ("Didn't call inherited Read - 3");
      end if;

      if X2 /=
        (D  => 7, S => Str (Ident_Str ("g")), C1 => Ident_Int (7),
         C3 => Int (Ident_Int (666)))
      then
         Failed ("Read and Write are not inverses of each other - 3");
      end if;

      begin
         Derived2'Output (S'Access, Y1);
         if Int_Ops.Get_Counts /=
           (Read => 5, Write => 7, Input => 0, Output => 0) then
            Failed ("Error writing extension components - 4");
         end if;
         if Parent_Ops.Get_Counts /=
           (Read => 3, Write => 4, Input => 0, Output => 0) then
            Failed ("Didn't call inherited Write - 4");
         end if;
      exception
         when Input_Output_Error =>
            Failed ("Did call inherited Output - 4");
      end;

      begin
         declare
            Y2 : Derived2 := Derived2'Input (S'Access);
         begin
            if Int_Ops.Get_Counts /=
              (Read => 7, Write => 7, Input => 0, Output => 0) then
               Failed ("Error reading extension components - 4");
            end if;
            if Parent_Ops.Get_Counts /=
              (Read => 4, Write => 4, Input => 0, Output => 0) then
               Failed ("Didn't call inherited Read - 4");
            end if;
            if Y2 /=
              (D  => 8, S => Str (Ident_Str ("8")), C1 => Ident_Int (7),
               C3 => Int (Ident_Int (77)))
            then
               Failed ("Input and Output are not inverses of each other - 4");
            end if;
         end;
      exception
         when Input_Output_Error =>
            Failed ("Did call inherited Input - 4");
      end;

   end Test2;

   Result;
end Cdd2a01;
