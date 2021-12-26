{
  description = "Built LaTeX document";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        packages = with pkgs; [
          (texlive.combine {
            inherit (texlive)
              scheme-medium
              framed
              titlesec
              cleveref
              multirow
              wrapfig
              tabu
              threeparttable
              threeparttablex
              makecell
              environ
              biblatex
              biber
              minted
              fvextra
              upquote
              catchfile
              xstring
              footmisc
              csquotes
              comment
              xltabular
              ltablex
              tikzscale
              pgfplots
              pgfgantt
              chngcntr
              dejavu
              ;
          })
          pandoc
          which
          python39Packages.pygments
        ];

        dev-packages = with pkgs; [
          texlab
          zathura
          wmctrl
        ];

        document-build = { self, name ? "document.pdf" }:
          with import nixpkgs { system = "${system}"; };
          pkgs.stdenvNoCC.mkDerivation rec {
            src = self;
            inherit name;

            buildInputs = [
              packages
            ];

            TEXMFHOME = "./cache";
            TEXMFVAR = "./cache/var";
            SOURCE_DATE_EPOCH = toString self.lastModified;

            buildPhase = ''
              latexmk
            '';

            installPhase = ''
              mkdir $out
              cp 010-main.pdf $out/${name}
            '';
          };

      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            packages
            dev-packages
          ];
        };

        packages = flake-utils.lib.flattenTree {
          pdf = document-build { inherit self; name = "TFG_Hilbert.pdf"; };
        };

        defaultPackage = self.packages.${system}.pdf;
      }
    );

}
