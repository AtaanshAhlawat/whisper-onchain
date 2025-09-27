"use client";

import { useState } from "react";
import { useAccount } from "wagmi";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { Address } from "~~/components/scaffold-eth";

const FeedbackPage = () => {
  const { address: connectedAddress } = useAccount();
  const [feedbackContent, setFeedbackContent] = useState("");
  const [feedbackCategory, setFeedbackCategory] = useState(0);
  const [feedbackMetadata, setFeedbackMetadata] = useState("");

  const { writeContractAsync: writeAnonymousFeedbackAsync } = useScaffoldWriteContract({
    contractName: "AnonymousFeedback",
  });

  const { data: stats } = useScaffoldReadContract({
    contractName: "AnonymousFeedback",
    functionName: "getStats",
  });

  const { data: latestFeedbackIds } = useScaffoldReadContract({
    contractName: "AnonymousFeedback",
    functionName: "getLatestFeedbackIds",
    args: [10, 0],
  });

  const handleSubmitFeedback = async () => {
    if (!feedbackContent.trim()) {
      alert("Please enter feedback content");
      return;
    }

    try {
      await writeAnonymousFeedbackAsync({
        functionName: "submitFeedback",
        args: [feedbackContent, feedbackCategory, feedbackMetadata],
      });
      
      setFeedbackContent("");
      setFeedbackMetadata("");
      alert("Feedback submitted successfully!");
    } catch (error) {
      console.error("Error submitting feedback:", error);
      alert("Error submitting feedback");
    }
  };

  const getCategoryName = (category: number) => {
    switch (category) {
      case 0: return "Positive";
      case 1: return "Constructive";
      case 2: return "Ideas";
      default: return "Unknown";
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8">Whisper OnChain</h1>
        <p className="text-center text-lg mb-8">Anonymous Feedback Board</p>
        
        {connectedAddress ? (
          <div className="mb-6">
            <p className="text-center">Connected as: <Address address={connectedAddress} /></p>
          </div>
        ) : (
          <div className="alert alert-warning mb-6">
            <p>Please connect your wallet to submit feedback</p>
          </div>
        )}

        {/* Stats */}
        {stats && (
          <div className="stats shadow mb-8">
            <div className="stat">
              <div className="stat-title">Total Feedback</div>
              <div className="stat-value">{stats[0]?.toString() || "0"}</div>
            </div>
            <div className="stat">
              <div className="stat-title">Total Votes</div>
              <div className="stat-value">{stats[1]?.toString() || "0"}</div>
            </div>
            <div className="stat">
              <div className="stat-title">Active Feedback</div>
              <div className="stat-value">{stats[2]?.toString() || "0"}</div>
            </div>
          </div>
        )}

        {/* Submit Feedback Form */}
        <div className="card bg-base-100 shadow-xl mb-8">
          <div className="card-body">
            <h2 className="card-title">Submit Anonymous Feedback</h2>
            
            <div className="form-control">
              <label className="label">
                <span className="label-text">Feedback Content</span>
              </label>
              <textarea
                className="textarea textarea-bordered h-24"
                placeholder="Share your honest feedback..."
                value={feedbackContent}
                onChange={(e) => setFeedbackContent(e.target.value)}
                maxLength={1000}
              />
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text">Category</span>
              </label>
              <select
                className="select select-bordered"
                value={feedbackCategory}
                onChange={(e) => setFeedbackCategory(Number(e.target.value))}
              >
                <option value={0}>Positive</option>
                <option value={1}>Constructive</option>
                <option value={2}>Ideas</option>
              </select>
            </div>

            <div className="form-control">
              <label className="label">
                <span className="label-text">Tags (optional)</span>
              </label>
              <input
                type="text"
                className="input input-bordered"
                placeholder="e.g., feature, bug, suggestion"
                value={feedbackMetadata}
                onChange={(e) => setFeedbackMetadata(e.target.value)}
                maxLength={200}
              />
            </div>

            <div className="card-actions justify-end">
              <button
                className="btn btn-primary"
                onClick={handleSubmitFeedback}
                disabled={!connectedAddress || !feedbackContent.trim()}
              >
                Submit Feedback
              </button>
            </div>
          </div>
        </div>

        {/* Recent Feedback */}
        <div className="card bg-base-100 shadow-xl">
          <div className="card-body">
            <h2 className="card-title">Recent Feedback</h2>
            {latestFeedbackIds && latestFeedbackIds.length > 0 ? (
              <div className="space-y-4">
                {latestFeedbackIds.map((feedbackId) => (
                  <FeedbackCard key={feedbackId.toString()} feedbackId={feedbackId} />
                ))}
              </div>
            ) : (
              <p>No feedback yet. Be the first to submit!</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

const FeedbackCard = ({ feedbackId }: { feedbackId: bigint }) => {
  const { data: feedback } = useScaffoldReadContract({
    contractName: "AnonymousFeedback",
    functionName: "getFeedback",
    args: [feedbackId],
  });

  const { writeContractAsync: writeAnonymousFeedbackAsync } = useScaffoldWriteContract({
    contractName: "AnonymousFeedback",
  });

  const handleVote = async (voteType: number) => {
    try {
      await writeAnonymousFeedbackAsync({
        functionName: "voteOnFeedback",
        args: [feedbackId, voteType],
      });
    } catch (error) {
      console.error("Error voting:", error);
    }
  };

  if (!feedback) return <div className="skeleton h-20 w-full"></div>;

  const getCategoryName = (category: number) => {
    switch (category) {
      case 0: return "Positive";
      case 1: return "Constructive";
      case 2: return "Ideas";
      default: return "Unknown";
    }
  };

  const getCategoryColor = (category: number) => {
    switch (category) {
      case 0: return "badge-success";
      case 1: return "badge-warning";
      case 2: return "badge-info";
      default: return "badge-neutral";
    }
  };

  return (
    <div className="card bg-base-200">
      <div className="card-body">
        <div className="flex justify-between items-start mb-2">
          <span className={`badge ${getCategoryColor(Number(feedback.category))}`}>
            {getCategoryName(Number(feedback.category))}
          </span>
          <span className="text-sm text-base-content/70">
            #{feedback.id.toString()}
          </span>
        </div>
        
        <p className="mb-3">{feedback.content}</p>
        
        {feedback.metadata && (
          <div className="mb-3">
            <span className="text-sm text-base-content/70">Tags: {feedback.metadata}</span>
          </div>
        )}
        
        <div className="flex justify-between items-center">
          <div className="flex gap-2">
            <button
              className="btn btn-sm btn-outline"
              onClick={() => handleVote(0)}
            >
              👍 {feedback.upvotes.toString()}
            </button>
            <button
              className="btn btn-sm btn-outline"
              onClick={() => handleVote(1)}
            >
              👎 {feedback.downvotes.toString()}
            </button>
          </div>
          
          <span className="text-sm text-base-content/70">
            {new Date(Number(feedback.timestamp) * 1000).toLocaleDateString()}
          </span>
        </div>
      </div>
    </div>
  );
};

export default FeedbackPage;
