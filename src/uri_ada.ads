package URI_Ada with Preelaborate is

   --  Helper functions to identify URLs and their components.
   --
   --  See https://tools.ietf.org/html/rfc3986 for full details.
   --
   --  http://user:pass@www.here.com:80/dir1/dir2/xyz.html?p=8&x=doh#anchor
   --   |                    |       | |          |       |         |
   --   protocol             host port path       file   parameters fragment
   --
   --        foo://example.com:8042/over/there?name=ferret#nose
   --        \_/   \______________/\_________/ \_________/ \__/
   --         |           |            |            |        |
   --      scheme     authority       path        query   fragment
   --         |   _____________________|__
   --        / \ /                        \
   --        urn:example:animal:ferret:nose

   type Parts is
     (Scheme,
      Authority,
      Path,
      Query,
      Fragment);

   ---------------
   -- Low level --
   ---------------

   --  The following functions will return "" for any part not recognized. Note
   --  that no part is mandatory, so any "malformed" URI will be recognized as
   --  a mere Path.

   function Extract (This : String; Part : Parts) return String;
   --  Return a specific part of the URL, or "" if not present

   function Extract (This : String; First, Last : Parts) return String;
   --  Return a slice of parts, or "" if none exist in the slice. Note that
   --  appropriate separators will be included between parts: ":" after
   --  existing scheme, "//" if authority exists, "?" if query exists, "#" if
   --  fragment exists. Note that separators will not be included before First
   --  nor after Last parts. Note that Scheme .. Path of "file:///path/to" will
   --  return "file:/path/to" because authority is empty.
   --
   --  NOTES on "file:" URIs. Since the Authority only ends when a third '/' is
   --  found, the following URIs may have unexpected interpretations (but these
   --  are the correct ones!):
   --
   --  file://hello.txt => authority: hello.txt, path: ""
   --  file:///hello.txt => authority: "", path: /hello.txt
   --  file:../relative => authority: "", path: ../relative
   --  file://../relative => authority: "..", path: /relative
   --  file:/absolute => authority: "", path: /absolute
   --
   --  TL;DR: to ensure proper interpretation of malformed file: URLs, take
   --  both the slice Authority .. Path as a whole to be the complete path.
   --  Or use Permissive_Path below.

   ----------------
   -- High level --
   ----------------

   function Scheme (This : String) return String
   is (Extract (This, Scheme));

   function Permissive_Path (This : String) return String
   is (Extract (This, Authority, Path));

   subtype Authority_String is String;
   function User (This : Authority_String) return String;
   function Password (This : Authority_String) return String;
   --  These operate on a previously extracted authority part, not a full URL.
   --  They will return an empty string if the corresponding part is missing

end URI_Ada;
