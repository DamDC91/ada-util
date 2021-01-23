-----------------------------------------------------------------------
--  util-streams-buffered-lzma-tests -- Unit tests for encoding buffered streams
--  Copyright (C) 2018, 2019, 2021 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Util.Test_Caller;
with Util.Streams.Files;
with Util.Streams.Texts;
with Ada.Streams.Stream_IO;
package body Util.Streams.Buffered.Lzma.Tests is

   use Util.Streams.Files;
   use Ada.Streams.Stream_IO;

   package Caller is new Util.Test_Caller (Test, "Streams.Buffered.Lzma");

   procedure Add_Tests (Suite : in Util.Tests.Access_Test_Suite) is
   begin
      Caller.Add_Test (Suite, "Test Util.Streams.Buffered.Lzma.Write",
                       Test_Compress_Stream'Access);
      Caller.Add_Test (Suite, "Test Util.Streams.Buffered.Lzma.Write (2)",
                       Test_Compress_File_Stream'Access);
   end Add_Tests;

   procedure Test_Compress_Stream (T : in out Test) is
      Stream  : aliased File_Stream;
      Buffer  : aliased Util.Streams.Buffered.Lzma.Compress_Stream;
      Print   : Util.Streams.Texts.Print_Stream;
      Path    : constant String := Util.Tests.Get_Test_Path ("test-stream.lzma");
      Expect  : constant String := Util.Tests.Get_Path ("regtests/expect/test-stream.lzma");
   begin
      Stream.Create (Mode => Out_File, Name => Path);
      Buffer.Initialize (Output => Stream'Access,
                         Size   => 1024);
      Print.Initialize (Output => Buffer'Access, Size => 5);
      for I in 1 .. 32 loop
         Print.Write ("abcd");
         Print.Write (" fghij");
         Print.Write (ASCII.LF);
      end loop;
      Print.Flush;
      Stream.Close;

      Util.Tests.Assert_Equal_Files (T       => T,
                                     Expect  => Expect,
                                     Test    => Path,
                                     Message => "LZMA stream");
   end Test_Compress_Stream;

   procedure Test_Compress_File_Stream (T : in out Test) is
      Stream    : aliased File_Stream;
      In_Stream : aliased File_Stream;
      Buffer    : aliased Util.Streams.Buffered.Lzma.Compress_Stream;
      Path      : constant String
        := Util.Tests.Get_Test_Path ("test-big-stream.lzma");
      Expect    : constant String
        := Util.Tests.Get_Path ("regtests/expect/test-big-stream.lzma");
   begin
      In_Stream.Open (Ada.Streams.Stream_IO.In_File,
                      Util.Tests.Get_Path ("regtests/files/test-big-stream.bin"));
      Stream.Create (Mode => Out_File, Name => Path);
      Buffer.Initialize (Output => Stream'Access,
                         Size   => 32768);
      Util.Streams.Copy (From => In_Stream, Into => Buffer);
      Buffer.Flush;
      Buffer.Close;
      Util.Tests.Assert_Equal_Files (T       => T,
                                     Expect  => Expect,
                                     Test    => Path,
                                     Message => "LZMA stream");
   end Test_Compress_File_Stream;

end Util.Streams.Buffered.Lzma.Tests;
