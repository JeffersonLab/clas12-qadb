// run `calculateGapCharge.groovy` first, then this macro
void analyzeGapCharge(TString datFileN = "charge_gaps.dat") {

  // read the input
  auto tr = new TTree("tr", "tr");
  tr->ReadFile(datFileN);

  // set tree branch addresses
  Int_t runnum, binnum, runset, golden, lastBin;
  Char_t comment[1000];
  Double_t chargeGap, chargeMin, chargeMax;
  Double_t chargeGapMin=1e6;
  Double_t chargeGapMax=-1e6;
  Double_t chargeRatMin=1e6;
  Double_t chargeRatMax=-1e6;
  tr->SetBranchAddress("runnum", &runnum);
  tr->SetBranchAddress("binnum", &binnum);
  tr->SetBranchAddress("runset", &runset);
  tr->SetBranchAddress("golden", &golden);
  tr->SetBranchAddress("lastBin", &lastBin);
  tr->SetBranchAddress("comment", comment);
  tr->SetBranchAddress("fcChargeMin", &chargeMin);
  tr->SetBranchAddress("fcChargeMax", &chargeMax);
  tr->SetBranchAddress("fcChargeGapToNextBin", &chargeGap);

  // get plot ranges and initialize charge accumulators
  std::map<Int_t, TString> runsets;
  runsets[-1] = "full_run_list";
  enum charge_calc { kAllFiles, kGoldenFiles, kFullRunMin, kFullRunMax };
  std::map<Int_t, std::map<charge_calc, Double_t>> chargeTot;
  for(Long64_t e = 0; e < tr->GetEntries(); e++) {
    tr->GetEntry(e);
    runsets[runset] = comment;
    chargeTot[runnum] = {
      {kAllFiles,    0},
      {kGoldenFiles, 0},
      {kFullRunMin,  1e7},
      {kFullRunMax,  0}
    };
    if(!lastBin) {
      chargeGapMin = std::min(chargeGapMin, chargeGap);
      chargeGapMax = std::max(chargeGapMax, chargeGap);
      chargeRatMin = std::min(chargeRatMin, chargeGap / (chargeMax-chargeMin));
      chargeRatMax = std::max(chargeRatMax, chargeGap / (chargeMax-chargeMin));
    }
  }

  // define plots
  std::map<Int_t, TH1D*> gapDists;
  std::map<Int_t, TH1D*> ratDists;
  std::map<Int_t, TGraph*> gapVsBinNum;
  std::map<Int_t, TGraph*> ratVsBinNum;
  for(auto const& [r, c] : runsets) {
    gapDists.insert({r, new TH1D(
          Form("gapDist_%d", r),
          TString("Gap charge distribution: ") + c + ";gap [nC]",
          100000,
          chargeGapMin,
          chargeGapMax
          )});
    ratDists.insert({r, new TH1D(
          Form("ratDist_%d", r),
          TString("Gap charge / bin charge: ") + c + ";gap/bin",
          100000,
          chargeRatMin,
          chargeRatMax
          )});
    gapVsBinNum.insert({r, new TGraph()});
    gapVsBinNum[r]->SetName(Form("gapVsBinNum_%d", r));
    gapVsBinNum[r]->SetTitle(TString("Gap charge vs bin num: ") + c + TString(";runnum + binnum/1e5;gap [nC]"));
    gapVsBinNum[r]->SetMarkerStyle(kFullCircle);
    ratVsBinNum.insert({r, new TGraph()});
    ratVsBinNum[r]->SetName(Form("ratVsBinNum_%d", r));
    ratVsBinNum[r]->SetTitle(TString("Gap charge / bin charge vs bin num: ") + c + TString(";runnum + binnum/1e5;gap/bin"));
    ratVsBinNum[r]->SetMarkerStyle(kFullCircle);
  }

  // fill plots and accumulate charge
  for(Long64_t e = 0; e < tr->GetEntries(); e++) {
    tr->GetEntry(e);
    auto charge = chargeMax - chargeMin;
    if(golden==1 && lastBin==0) {
      for(auto const& [r, c] : runsets) {
        if(r >= 0 && runset != r) continue;
        auto chargeRat = chargeGap / charge;
        auto runbin = runnum + static_cast<double>(binnum)/1e5;
        gapDists.at(r)->Fill(chargeGap);
        ratDists.at(r)->Fill(chargeRat);
        gapVsBinNum.at(r)->AddPoint(runbin, chargeGap);
        ratVsBinNum.at(r)->AddPoint(runbin, chargeRat);
      }
    }
    chargeTot[runnum][kAllFiles] += charge;
    if(golden) chargeTot[runnum][kGoldenFiles] += charge;
    chargeTot[runnum][kFullRunMin] = std::min(chargeMin, chargeTot[runnum][kFullRunMin]);
    chargeTot[runnum][kFullRunMax] = std::max(chargeMax, chargeTot[runnum][kFullRunMax]);
  }

  // draw plots
  auto canv1 = new TCanvas();
  canv1->Divide(2,2);
  Int_t padnum = 1;
  for(auto const& [r, c] : runsets) {
    auto pad = canv1->GetPad(padnum++);
    // pad->SetLogy();
    pad->cd();
    gapDists.at(r)->Draw();
    // gapDists.at(r)->GetXaxis()->SetRangeUser(-1000, 1000);
  }
  auto canv2 = new TCanvas();
  canv2->Divide(2,2);
  padnum = 1;
  for(auto const& [r, c] : runsets) {
    auto pad = canv2->GetPad(padnum++);
    // pad->SetLogy();
    pad->cd();
    ratDists.at(r)->Draw();
    // ratDists.at(r)->GetXaxis()->SetRangeUser(-1000, 1000);
  }
  auto canv3 = new TCanvas();
  canv3->Divide(2,2);
  padnum = 1;
  for(auto const& [r, c] : runsets) {
    auto pad = canv3->GetPad(padnum++);
    pad->cd();
    gapVsBinNum.at(r)->Draw("ap");
  }
  auto canv4 = new TCanvas();
  canv4->Divide(2,2);
  padnum = 1;
  for(auto const& [r, c] : runsets) {
    auto pad = canv4->GetPad(padnum++);
    pad->cd();
    ratVsBinNum.at(r)->Draw("ap");
  }

  // cross check the accumulated charge
  std::cout << "CHARGE CROSS CHECK" << std::endl << "==================" << std::endl;
  std::cout << "    (1) run num       (2) golden files' sum       (3) all files' sum       (4) run's max-min       100 * [1 - (3)/(4)]" << std::endl;
  for(auto const& [run_num, charge_hash] : chargeTot) {
    auto runCharge = charge_hash.at(kFullRunMax) - charge_hash.at(kFullRunMin);
    std::cout << ">>> " <<
      run_num << "       " <<
      charge_hash.at(kGoldenFiles) << "       " <<
      charge_hash.at(kAllFiles) << "       " <<
      runCharge << "       " <<
      100.0 * (1 - charge_hash.at(kAllFiles) / runCharge) << "%" <<
      std::endl;
  }
}
