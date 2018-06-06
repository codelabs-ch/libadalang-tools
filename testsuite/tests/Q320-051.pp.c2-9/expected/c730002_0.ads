-- C730002.A
--
--                             Grant of Unlimited Rights
--
--     Under contracts F33600-87-D-0337, F33600-84-D-0280, MDA903-79-C-0687,
--     F08630-91-C-0015, and DCA100-97-D-0025, the U.S. Government obtained
--     unlimited rights in the software and documentation contained herein.
--     Unlimited rights are defined in DFAR 252.227-7013(a)(19).  By making
--     this public release, the Government intends to confer upon all
--     recipients unlimited rights  equal to those held by the Government.
--     These rights include rights to use, duplicate, release or disclose the
--     released technical data and computer software in whole or in part, in
--     any manner and for any purpose whatsoever, and to have or permit others
--     to do so.
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
--      Check that the full view of a private extension may be derived
--      indirectly from the ancestor type (i.e., the parent type of the full
--      type may be any descendant of the ancestor type). Check that, for
--      a primitive subprogram of the private extension that is inherited from
--      the ancestor type and not overridden, the formal parameter names and
--      default expressions come from the corresponding primitive subprogram
--      of the ancestor type, while the body comes from that of the parent
--      type.
--      Check for a case where the parent type is derived from the ancestor
--      type through a series of types produced by generic instantiations.
--      Examine both the static and dynamic binding cases.
--
-- TEST DESCRIPTION:
--      Consider:
--
--      package P is
--         type Ancestor is tagged ...
--         procedure Op (P1: Ancestor; P2: Boolean := True);
--      end P;
--
--      with P;
--      generic
--         type T is new P.Ancestor with private;
--      package Gen1 is
--         type Enhanced is new T with private;
--         procedure Op (A: Enhanced; B: Boolean := True);
--         -- other specific procedures...
--      private
--         type Enhanced is new T with ...
--      end Gen1;
--
--      with P, Gen1;
--      package N is new Gen1 (P.Ancestor);
--
--      with N;
--      generic
--         type T is new N.Enhanced with private;
--      package Gen2 is
--         type Enhanced_Again is new T with private;
--         procedure Op (X: Enhanced_Again; Y: Boolean := False);
--         -- other specific procedures...
--      private
--         type Enhanced_Again is new T with ...
--      end Gen2;
--
--      with N, Gen2;
--      package Q is new Gen2 (N.Enhanced);
--
--      with P, Q;
--      package R is
--         type Priv_Ext is new P.Ancestor with private;         -- (A)
--         -- Inherits procedure Op (P1: Priv_Ext; P2: Boolean := True);
--         -- But body executed is that of Q.Op.
--      private
--         type Priv_Ext is new Q.Enhanced_Again with record ... -- (B)
--      end R;
--
--      The ancestor type in (A) differs from the parent type in (B); the
--      parent of the full type is descended from the ancestor type of the
--      private extension, in this case through a series of types produced
--      by generic instantiations.  Gen1 redefines the implementation of Op
--      for any type that has one.  N is an instance of Gen1 for the ancestor
--      type. Gen2 again redefines the implementation of Op for any type that
--      has one. Q is an instance of Gen2 for the extension of the P.Ancestor
--      declared in N.  Both N and Q could define other operations which we
--      don't want to be available in R.  For a call to Op (from outside the
--      scope of the full view) with an operand of type R.Priv_Ext, the body
--      executed will be that of Q.Op (the parent type's version), but the
--      formal parameter names and default expression come from that of P.Op
--      (the ancestor type's version).
--
--
-- CHANGE HISTORY:
--      06 Dec 94   SAIC    ACVC 2.0
--      27 Feb 97   CTA.PWB Added elaboration pragmas.
--!

package C730002_0 is

   type Hours_Type is range 0 .. 1_000;
   type Personnel_Type is range 0 .. 10;
   type Specialist_Id is (Manny, Moe, Jack, Curly, Joe, Larry);

   type Engine_Type is tagged record
      Ave_Repair_Time    : Hours_Type     := 0;     -- Default init. for
      Personnel_Required : Personnel_Type := 0;     -- component fields.
      Specialist         : Specialist_Id  := Manny;
   end record;

   procedure Routine_Maintenance
     (Engine : in out Engine_Type; Specialist : in Specialist_Id := Moe);

   -- The Routine_Maintenance procedure implements the processing required for
   -- an engine.

end C730002_0;
