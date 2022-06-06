with Ada.Assertions;
with Ada.Text_IO; use Ada.Text_IO;

procedure URI_Ada.Test is
   T_1 : constant String :=
           "http://anon:1234@www.dummy.com/highway/to/?sure&really#hell";
   T_2 : constant String := "urn:example:animal:ferret:nose";
begin

   --  Individual parts

   pragma Assert (Extract ("", Scheme) = "");
   pragma Assert (Extract ("file:", Scheme) = "file");
   pragma Assert (Extract (" file:", Scheme) = "file"); -- leading whitespace
   pragma Assert (Extract ("#space ", Fragment) = "space"); -- lagging whitespace
   pragma Assert (Extract ("#space", Path) = ""); -- Empty path

   pragma Assert (Extract (T_1, Scheme) = "http");
   pragma Assert (Extract (T_1, Authority) = "anon:1234@www.dummy.com");
   pragma Assert (Extract (T_1, Path) = "/highway/to/");
   pragma Assert (Extract (T_1, Query) = "sure&really");
   pragma Assert (Extract (T_1, Fragment) = "hell");

   pragma Assert (Extract (T_2, Scheme) = "urn");
   pragma Assert (Extract (T_2, Authority) = "");
   pragma Assert (Extract (T_2, Path) = "example:animal:ferret:nose");
   pragma Assert (Extract (T_2, Query) = "");
   pragma Assert (Extract (T_2, Fragment) = "");

   --  Bizarre individual parts

   pragma Assert (Extract ("git+http:", Scheme) = "git+http");
   pragma Assert (Extract ("http::nowhere", Scheme) = "http");
   pragma Assert (Extract ("http::nowhere", Path) = ":nowhere");

   pragma Assert (Extract ("///auth", Authority) = "");
   pragma Assert (Extract ("///auth", Path) = "/auth");

   pragma Assert (Extract ("//+auth", Authority) = "+auth");
   pragma Assert (Extract ("//?auth", Authority) = "");
   pragma Assert (Extract ("//#auth", Authority) = "");
   pragma Assert (Extract ("//../uh/oh", Authority) = "..");

   pragma Assert (Extract ("//?", Path) = "");
   pragma Assert (Extract ("///+asdf?", Path) = "/+asdf");
   pragma Assert (Extract ("//../uh/oh", Path) = "/uh/oh");

   pragma Assert (Extract ("??", Query) = "?");
   pragma Assert (Extract ("?#", Query) = "");
   pragma Assert (Extract ("??&#?", Query) = "?&");
   pragma Assert (Extract ("?&#?", Query) = "&");

   pragma Assert (Extract ("??&#?", Fragment) = "?");
   pragma Assert (Extract ("#", Fragment) = "");
   pragma Assert (Extract ("##", Fragment) = "#");

   --  Counterintuitive Authority/Path combos

   pragma Assert (Extract ("file://hello.txt", Authority) = "hello.txt");
   pragma Assert (Extract ("file://hello.txt", Path) = "");
   pragma Assert (Permissive_Path ("file://hello.txt") = "hello.txt");

   pragma Assert (Extract ("file:///hello.txt", Authority) = "");
   pragma Assert (Extract ("file:///hello.txt", Path) = "/hello.txt");
   pragma Assert (Permissive_Path ("file:///hello.txt") = "/hello.txt");

   pragma Assert (Extract ("file:../hello.txt", Authority) = "");
   pragma Assert (Extract ("file:../hello.txt", Path) = "../hello.txt");
   pragma Assert (Permissive_Path ("file:../hello.txt") = "../hello.txt");

   pragma Assert (Extract ("file://../hello.txt", Authority) = "..");
   pragma Assert (Extract ("file://../hello.txt", Path) = "/hello.txt");
   pragma Assert (Permissive_Path ("file://../hello.txt") = "../hello.txt");

   pragma Assert (Extract ("file:/hello.txt", Authority) = "");
   pragma Assert (Extract ("file:/hello.txt", Path) = "/hello.txt");
   pragma Assert (Permissive_Path ("file:/hello.txt") = "/hello.txt");

   --  Slices

   pragma Assert (Extract ("file:///path/to", Scheme, Path) = "file:/path/to");
   pragma Assert (Extract ("file:///path/to", Authority, Authority) = "");

   pragma Assert (Extract (T_1, Scheme, Fragment) = T_1);
   pragma Assert (Extract (T_1, Authority, Query) = "anon:1234@www.dummy.com/highway/to/?sure&really");
   pragma Assert (Extract (T_1, Path, Query) = "/highway/to/?sure&really");
   pragma Assert (Extract (T_1, Scheme, Authority) = "http://anon:1234@www.dummy.com");
   pragma Assert (Extract (T_1, Authority, Path) = "anon:1234@www.dummy.com/highway/to/");

   pragma Assert (Extract (T_2, Scheme, Fragment) = T_2);
   pragma Assert (Extract (T_2, Authority, Query) = "example:animal:ferret:nose");
   pragma Assert (Extract (T_2, Path, Query) = "example:animal:ferret:nose");
   pragma Assert (Extract (T_2, Scheme, Authority) = "urn");
   pragma Assert (Extract (T_2, Scheme, Path) = T_2);
   pragma Assert (Extract (T_2, Authority, Path) = "example:animal:ferret:nose");

   --  User/Pass

   pragma Assert (User (Extract ("https://nouser", Authority)) = "");
   pragma Assert (User (Extract ("https://user@nopass", Authority)) = "user");
   pragma Assert (User (Extract ("https://user:pass@nopass", Authority)) = "user");

   pragma Assert (Password (Extract ("https://nouser", Authority)) = "");
   pragma Assert (Password (Extract ("https://user@nopass", Authority)) = "");
   pragma Assert (Password (Extract ("https://user:pass@nopass", Authority)) = "pass");

   --  Ensure that assertions are being checked
   begin
      pragma Assert (False);
      raise Program_Error;
   exception
      when Ada.Assertions.Assertion_Error =>
         Put_Line ("OK");
   end;

end URI_Ada.Test;
