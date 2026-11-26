<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ClippedNews;
use Illuminate\Http\Request;

class ClippedNewsController extends Controller
{
    public function index(Request $request)
    {
        $query = ClippedNews::with('mission')->where('user_id', auth()->id());
        
        if ($request->has('mission_id') && $request->mission_id != '') {
            $query->where('mission_id', $request->mission_id);
        }

        return response()->json($query->latest()->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'mission_id' => 'required|exists:missions,id',
            'title' => 'required|string',
            'news_site' => 'nullable|string',
            'image_url' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $news = ClippedNews::create([
            'user_id' => auth()->id(),
            'mission_id' => $request->mission_id,
            'title' => $request->title,
            'news_site' => $request->news_site,
            'image_url' => $request->image_url,
            'notes' => $request->notes,
        ]);

        return response()->json($news->load('mission'), 201);
    }

    public function update(Request $request, $id)
    {
        $news = ClippedNews::where('user_id', auth()->id())->findOrFail($id);
        $request->validate([
            'mission_id' => 'required|exists:missions,id',
            'title' => 'required|string',
            'news_site' => 'nullable|string',
            'image_url' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        $news->update($request->only(['mission_id', 'title', 'news_site', 'image_url', 'notes']));
        return response()->json($news->load('mission'));
    }

    public function destroy($id)
    {
        $news = ClippedNews::where('user_id', auth()->id())->findOrFail($id);
        $news->delete();
        return response()->json(['message' => 'Berita dihapus dari koleksi']);
    }
}