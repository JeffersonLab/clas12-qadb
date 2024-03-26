// run `calculateGapCharge.groovy` first, then this macro
void analyzeGapCharge(TString datFileN = "charge_gaps.dat") {
  auto tr = new TTree("tr", "tr");
  tr->ReadFile(datFileN);
  tr->Print();

  Int_t runset;
  Char_t comment[1000];
  Double_t chargeGap;
  Double_t chargeGapMin=1e6;
  Double_t chargeGapMax=-1e6;
  tr->SetBranchAddress("runset", &runset);
  tr->SetBranchAddress("comment", comment);
  tr->SetBranchAddress("fcChargeGapToNextBin", &chargeGap);
  std::map<int, TString> runsets;
  runsets[-1] = "full_run_list";
  for(Long64_t e = 0; e < tr->GetEntries(); e++) {
    tr->GetEntry(e);
    runsets[runset] = comment;
    chargeGapMin = std::min(chargeGapMin, chargeGap);
    chargeGapMax = std::max(chargeGapMax, chargeGap);
  }
  std::cout << "chargeGapMin = " << chargeGapMin << std::endl;
  std::cout << "chargeGapMax = " << chargeGapMax << std::endl;

  std::map<int, TH1D*> gapDists;
  for(auto const& [r, c] : runsets) {
    gapDists.insert({r, new TH1D(
          Form("gapDist_%d", r),
          TString("Gap charge distribution: ") + c + ";gap [nC]",
          100000,
          chargeGapMin,
          chargeGapMax
          )});
  }

  auto canv = new TCanvas();
  canv->Divide(2,2);
  int padnum = 1;
  for(auto const& [r, c] : runsets) {
    TString cut = "golden == 1";
    if(r >= 0) cut += Form(" && runset == %d", r);
    tr->Project(gapDists.at(r)->GetName(), "fcChargeGapToNextBin", cut);
    auto pad = canv->GetPad(padnum++);
    // pad->SetLogy();
    pad->cd();
    gapDists.at(r)->Draw();
    // gapDists.at(r)->GetXaxis()->SetRangeUser(-1000, 1000);
  };
}
