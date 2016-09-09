------------------------------------------------------------------------------
--                                                                          --
--                  COMMON ASIS TOOLS COMPONENTS LIBRARY                    --
--                                                                          --
--                  A S I S _ U L . E N V I R O N M E N T                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--                    Copyright (C) 2004-2016, AdaCore                      --
--                                                                          --
-- Asis Utility Library (ASIS UL) is free software; you can redistribute it --
-- and/or  modify  it  under  terms  of  the  GNU General Public License as --
-- published by the Free Software Foundation; either version 3, or (at your --
-- option)  any later version.  ASIS UL  is distributed in the hope that it --
-- will  be  useful,  but  WITHOUT  ANY  WARRANTY; without even the implied --
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the --
-- GNU  General Public License for more details. You should have received a --
-- copy of the  GNU General Public License  distributed with GNAT; see file --
-- COPYING3. If not,  go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
--                                                                          --
-- ASIS UL is maintained by AdaCore (http://www.adacore.com).               --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_2012;

--  This package contains routines for creating, maintaining and cleaning up
--  the working environment for an ASIS tool

with GNAT.Directory_Operations; use GNAT.Directory_Operations;
with GNAT.OS_Lib;               use GNAT.OS_Lib;

with ASIS_UL.String_Utilities; use ASIS_UL.String_Utilities;
  use ASIS_UL.String_Utilities.String_Vectors;

package LAL_UL.Environment is

   procedure Create_Temp_Dir;
   --  Creates the temporary directory for all the compilations performed by
   --  the tool. Raises Fatal_Error if creating of the temporary directory
   --  failed because of any reason. Sets ASIS_UL.Environment.Tool_Temp_Dir.

   procedure Copy_Gnat_Adc;
   --  Copies the "gnat.adc" file from the Tool_Current_Dir to the
   --  Tool_Temp_Dir.

   procedure Clean_Up;
   --  Performs the general final clean-up actions, including closing and
   --  deleting of all files in the temporary directory and deleting this
   --  temporary directory itself.

   procedure Call_Builder;
   --  Used by the outer invocation in incremental mode to call the
   --  builder. Raises Fatal_Error on failure.

   Extra_Inner_Pre_Args, Extra_Inner_Post_Args : String_Vector;
   --  In Incremental_Mode, these may be used by the outer invocation of the
   --  tool to pass information to the inner invocations. The Pre ones go
   --  first; the Post ones go last.

   Initial_Dir : constant String := Normalize_Pathname (Get_Current_Dir);
   --  This is the current directory at the time the current process started.

   Tool_Current_Dir : String_Access;
   --  This is the full path name of the current directory when the user
   --  invoked the tool. This is the same as Initial_Dir, except in the case of
   --  an inner invocation.
   --
   --  If --outer-dir=/some/path was passed on the command line, then this is
   --  an inner invocation, and this is set to "/some/path". In incremental
   --  mode (with a project file), the builder sets the current directory for
   --  the inner invocations to a subdirectory of the object directory
   --  (Tool_Inner_Dir below). So the outer invocation passes --outer-dir to
   --  allow the inner one to find the original directory in which the tool was
   --  run. We switch to this directory during command-line processing, so we
   --  can find files based on what the user expects. For example, for
   --
   --     gnatcheck -rules -from-file=rules.txt
   --
   --  we want to look for rules.txt in the directory where gnatcheck was
   --  originally run from.
   --
   --  Thus, Tool_Current_Dir in the inner invocation is the same as
   --  Tool_Current_Dir in the outer invocation.

   Tool_Temp_Dir : String_Access;
   --  Contains the full path name of the temporary directory created by the
   --  ASIS tools for the tree files, etc.

   Tool_Inner_Dir : String_Access;
   --  For an inner invocation, this is the subdirectory of the object
   --  directory in which gprbuild invoked this process; it's the same as
   --  Initial_Dir. If this is not an inner invocation, this is null,
   --  and not used.

end LAL_UL.Environment;
