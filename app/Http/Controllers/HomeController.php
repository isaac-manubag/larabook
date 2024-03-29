<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Exports\UsersExport;
use PDF;
use Excel;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        return view('home');
    }

    public function viewTestPdf()
    {
        $pdf = PDF::loadView('pdf.testpdf');

        return $pdf->stream('test.pdf');
    }

    public function export() 
    {
        return Excel::download(new UsersExport, 'users.xlsx');
    }
}
