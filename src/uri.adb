with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with GNAT.Regpat;

package body URI is

   package Part_Maps is
     new Ada.Containers.Indefinite_Ordered_Maps (Parts, String);

   subtype Part_Map is Part_Maps.Map;

   -----------
   -- Crack --
   -----------

   --  ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?
   --   12            3  4          5       6  7        8 9
   --
   --  scheme    = $2
   --  authority = $4
   --  path      = $5
   --  query     = $7
   --  fragment  = $9

   function Crack (This : String) return Part_Map is
      use GNAT.Regpat;

      Cracker : constant Pattern_Matcher :=
                  Compile
                    ("^\s*(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#([^\s]*))?",
                     Case_Insensitive + Single_Line);

      Matches : Match_Array (0 .. 9) := (others => No_Match);

      function Part (I : Positive) return String
      is (if Matches (I) /= No_Match
          then This (Matches (I).First .. Matches (I).Last)
          else "");

   begin
      Match (Cracker, This, Matches);

      return Map : Part_Map do
         Map.Insert (Scheme,    Part (2));
         Map.Insert (Authority, Part (4));
         Map.Insert (Path,      Part (5));
         Map.Insert (Query,     Part (7));
         Map.Insert (Fragment,  Part (9));
      end return;
   end Crack;

   -------------
   -- Extract --
   -------------

   function Extract (This : String; Part : Parts) return String
   is (Extract (This, First => Part, Last => Part));

   -------------
   -- Extract --
   -------------

   function Extract (This : String; First, Last : Parts) return String
   is
      Slice : Unbounded_String;
      Parts : constant Part_Map := Crack (This);
   begin
      for I in First .. Last loop
         if Parts.Contains (I) then

            -- prefixes

            if I /= First and then Parts (I) /= "" and then Slice /= "" then
               case I is
               when Scheme    => null;
               when Authority => Append (Slice, "//");
               when Path      => null;
               when Query     => Append (Slice, "?");
               when Fragment  => Append (Slice, "#");
               end case;
            end if;

            Append (Slice, Parts (I));

            -- postfixes

            if I = Scheme and then Parts (I) /= "" and then Extract (This, Authority, Last) /= "" then
               Append (Slice, ":");
            end if;

         end if;
      end loop;

      return To_String (Slice);
   end Extract;

end URI;
